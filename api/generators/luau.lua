local preamble = [[
declare extern type userdata with end
declare extern type lightuserdata with end

]]

local genFunctionType

-- Documented as modules, reached as globals: there is no `lovr.vector`.
--
-- Each is also a type the fork layers onto Luau's own, and declaring one
-- replaces the builtin rather than extending it, so the fields and operators
-- are restated here alongside the generated methods. What is listed matches
-- what the runtime answers to: vectors are three-wide, and neither `#` nor `^`
-- is defined on one.
local globalModule = {
  vector = {
    fields = { 'x: number', 'y: number', 'z: number' },
    operators = {
      'function __add(self, other: vector): vector',
      'function __sub(self, other: vector): vector',
      'function __mul(self, other: vector): vector',
      'function __mul(self, other: number): vector',
      'function __div(self, other: vector): vector',
      'function __div(self, other: number): vector',
      'function __unm(self): vector'
    }
  },
  quaternion = {
    fields = { 'x: number', 'y: number', 'z: number', 'w: number' },
    operators = {
      'function __mul(self, other: quaternion): quaternion',
      'function __mul(self, other: vector): vector'
    }
  }
}

local genType

local function genTableType(info, mutable, input)
  if not info.table then return '{}' end

  local fields = {}
  for _, field in ipairs(info.table) do
    local name = field.name:gsub('%?$', '')
    local key = name:match('^[%a_][%w_]*$') and name or ('[%q]'):format(name)
    if mutable and (field.readType or field.writeType) then
      local readable, writable = {}, {}
      for k, v in pairs(field) do readable[k], writable[k] = v, v end
      readable.type = field.readType or field.type
      writable.type = field.writeType or field.type
      readable.default, writable.default = nil, nil
      table.insert(fields, ('read %s: %s, write %s: %s'):format(key, genType(readable, mutable, input), key, genType(writable, mutable, input)))
    else
      table.insert(fields, ('%s%s: %s'):format(mutable and '' or 'read ', key, genType(field, mutable, input)))
    end
  end
  return '{ ' .. table.concat(fields, ', ') .. ' }'
end

-- Split unions only outside array types, so an array of a union stays an array.
local function typeVariants(type)
  local variants, depth, start = {}, 0, 1
  for i = 1, #type do
    local char = type:sub(i, i)
    if char == '{' then depth = depth + 1
    elseif char == '}' then depth = depth - 1
    elseif char == '|' and depth == 0 then
      table.insert(variants, type:sub(start, i - 1):match('^%s*(.-)%s*$'))
      start = i + 1
    end
  end
  table.insert(variants, type:sub(start):match('^%s*(.-)%s*$'))
  return variants
end

-- `input` marks a type LÖVR reads from its caller: an argument, or a field of
-- one. An array there is read-only, `{ read [number]: T }`. LÖVR does not
-- write into it, and Luau compares a read-write indexer invariantly, so a
-- read-write array rejects a table literal passed to an overloaded function,
-- and a caller's `{integer}` where `{number}` is declared.
genType = function(info, mutable, input)
  mutable = info.mutable == nil and mutable or info.mutable
  local types = {}
  local optional = info.default ~= nil or (info.name and info.name:match('%?$')) or info.type:match('%?$')

  if info.values then
    for _, value in ipairs(info.values) do table.insert(types, ('%q'):format(value)) end
  else
    for _, variant in ipairs(typeVariants(info.type)) do
      optional = optional or variant:match('%?$')
      local t = variant:gsub('%?$', '')
      if t == 'function' then
        table.insert(types, genFunctionType(info))
      elseif t == '*' then
        table.insert(types, 'any')
      elseif t == 'table' then
        table.insert(types, genTableType(info, mutable, input))
      elseif t:match('^%{.*%}$') then
        local element = genType({ type = t:sub(2, -2) }, mutable, input)
        if input and not mutable then
          table.insert(types, '{ read [number]: ' .. element .. ' }')
        else
          table.insert(types, '{' .. element .. '}')
        end
      else
        table.insert(types, t)
      end
    end
  end

  if #types == 1 then
    local type = types[1]
    if optional and type:find('%->') then type = '(' .. type .. ')' end
    return type .. (optional and '?' or '')
  else
    return table.concat(types, ' | ') .. (optional and ' | nil' or '')
  end
end

local function genArguments(arguments, ismethod)
  local t = {}

  for _, arg in ipairs(arguments) do
    local name, type = arg.name, arg.alias or genType(arg, false, true)

    if name:match('%.%.%.') then
      if ismethod then
        table.insert(t, '...: ' .. type)
      else
        table.insert(t, '...' .. type)
      end
    else
      table.insert(t, ('%s: %s'):format(name, type))
    end
  end

  return table.concat(t, ', ')
end

local function genReturns(returns)
  local t = {}

  for _, ret in ipairs(returns) do
    local type = genType(ret)
    if ret.name and ret.name:match('%.%.%.') then
      table.insert(t, '...' .. type)
    else
      table.insert(t, type)
    end
  end

  return table.concat(t, ', ')
end

genFunctionType = function(fn)
  if not fn.arguments or not fn.returns then
    return '() -> ()'
  end

  local args = genArguments(fn.arguments)
  local rets = genReturns(fn.returns)

  if #fn.returns == 1 and fn.returns[1].type ~= 'function' then
    return ('(%s) -> %s'):format(args, rets)
  else
    return ('(%s) -> (%s)'):format(args, rets)
  end
end

local function genMethod(method, variant)
  local args = genArguments(variant.arguments, true)
  local rets = genReturns(variant.returns)

  if args == '' then
    args = 'self'
  else
    args = 'self, ' .. args
  end

  if #variant.returns > 1 or rets:match('%(') then
    rets = (': (%s)'):format(rets)
  elseif #variant.returns == 1 then
    rets = ': ' .. rets
  end

  return ('  function %s(%s)%s'):format(method.name, args, rets)
end

return function(api)
  local directory = lovr.filesystem.getSource() .. '/luau'

  if lovr.system.getOS() == 'Windows' then
    os.execute('mkdir ' .. directory:gsub('/', '\\'))
  else
    os.execute('mkdir -p ' .. directory)
  end

  local out = {}

  local function write(s, ...)
    table.insert(out, s:format(...))
  end

  write(preamble:gsub('^%s*', ''))
  write('\n')

  -- A variant taking nothing, next to one taking a variadic pack, is a call
  -- Luau cannot resolve: both accept zero arguments, and it reports the call as
  -- ambiguous rather than picking one. The variadic covers the empty case, so
  -- the empty variant is dropped where the two sit together. `lovr.math.newMat4()`
  -- and `lovr.graphics.newPass()` are the two this is for.
  local function usableVariants(fn)
    local variadic = false

    for _, variant in ipairs(fn.variants) do
      for _, argument in ipairs(variant.arguments) do
        if argument.name:match('%.%.%.') then
          variadic = true
        end
      end
    end

    if not variadic then
      return fn.variants
    end

    -- The variadic answers the empty call, so every other variant is written as
    -- taking at least its first argument. Without that, a variant whose
    -- arguments are all defaulted answers the empty call as well, and the
    -- ambiguity is back one arm along.
    local kept = {}
    for _, variant in ipairs(fn.variants) do
      if #variant.arguments > 0 then
        local arguments = {}

        for index, argument in ipairs(variant.arguments) do
          if index == 1 then
            local required = {}
            for key, value in pairs(argument) do
              required[key] = value
            end
            required.default = nil
            required.type = argument.type:gsub('%?$', '')
            table.insert(arguments, required)
          else
            table.insert(arguments, argument)
          end
        end

        table.insert(kept, { arguments = arguments, returns = variant.returns })
      end
    end

    return kept
  end

  local function writeFunction(fn)
    fn = { name = fn.name, variants = usableVariants(fn) }

    if #fn.variants > 1 then
      write('  %s:\n', fn.name)

      for i, variant in ipairs(fn.variants) do
        write('    & (%s)%s\n', genFunctionType(variant), i == #fn.variants and ',' or '')
      end
    else
      write('  %s: %s,\n', fn.name, genFunctionType(fn.variants[1]))
    end
  end

  for _, module in ipairs(api.modules) do
    for _, enum in ipairs(module.enums) do
      write('export type %s =\n', enum.name)
      for _, value in ipairs(enum.values) do
        write('  | %q\n', value.name)
      end
      write('\n')
    end

    -- Mat4 is not ignored: other signatures refer to it by name, so omitting it
    -- leaves the definitions unloadable. Vec2/Vec3/Vec4/Quat stay ignored and
    -- are not emitted regardless, since the docs express them as the native
    -- `vector` and `quaternion` types declared below.
    local ignore = {
      Vec2 = true,
      Vec3 = true,
      Vec4 = true,
      Quat = true,
      Vectors = true
    }

    local function writeObject(object)
      write('declare extern type %s', object.name)

      if object.extends then
        write(' extends %s', object.extends)
      end

      write(' with\n')

      for _, method in ipairs(object.methods) do
        for _, variant in ipairs(method.variants) do
          write('%s\n', genMethod(method, variant))
        end
      end

      write('end\n\n')
    end

    -- A type cannot be declared before the one it extends, and the objects
    -- arrive in alphabetical order, so `BallJoint` precedes `Joint`. Each base
    -- is emitted ahead of what extends it. A base from another module is
    -- already declared, and one that never becomes ready is a cycle in the
    -- metadata, so it is emitted anyway rather than dropped.
    local pending, here, emitted = {}, {}, {}
    for _, object in ipairs(module.objects) do
      if not ignore[object.name] then
        table.insert(pending, object)
        here[object.name] = true
      end
    end

    repeat
      local progressed = false
      for index, object in ipairs(pending) do
        if object ~= false and (not object.extends or not here[object.extends] or emitted[object.extends]) then
          writeObject(object)
          emitted[object.name] = true
          pending[index] = false
          progressed = true
        end
      end
    until not progressed

    for _, object in ipairs(pending) do
      if object ~= false then
        writeObject(object)
      end
    end

    if module.name ~= 'lovr' and #module.functions > 0 then
      write('export type %sModule = {\n', module.name:gsub('^%l', string.upper))

      for _, fn in ipairs(module.functions) do
        writeFunction(fn)
      end

      write('}\n\n')
    end
  end

  local aliases = {}
  for _, callback in ipairs(api.callbacks) do
    for _, variant in ipairs(callback.variants) do
      for _, argument in ipairs(variant.arguments) do
        if argument.alias and not aliases[argument.alias] then
          write('export type %s = %s\n\n', argument.alias, genType(argument))
          aliases[argument.alias] = true
        end
      end
    end
  end

  write('declare lovr: {\n')

  for _, module in ipairs(api.modules) do
    if module.name == 'lovr' then
      for _, fn in ipairs(module.functions) do
        writeFunction(fn)
      end
    end
  end

  write('\n')

  -- Every callback is optional. Nothing sets them by default and boot.lua tests
  -- each for presence before it calls one, so a declaration that says otherwise
  -- makes clearing a callback a type error.
  for _, callback in ipairs(api.callbacks) do
    if #callback.variants > 1 then
      write('  %s:\n', callback.name)

      for i, variant in ipairs(callback.variants) do
        write('    & (%s)%s\n', genFunctionType(variant), i == #callback.variants and '?,' or '')
      end
    else
      write('  %s: (%s)?,\n', callback.name, genFunctionType(callback.variants[1]))
    end
  end

  write('\n')

  for _, module in ipairs(api.modules) do
    if module.name ~= 'lovr' and #module.functions > 0 and not globalModule[module.name] then
      write('  %s: %sModule,\n', module.name, module.name:gsub('^%l', string.upper))
    end
  end

  write('}\n')

  for _, module in ipairs(api.modules) do
    local native = globalModule[module.name]
    if native and #module.functions > 0 then
      write('\ndeclare extern type %s with\n', module.name)

      for _, field in ipairs(native.fields) do
        write('  %s\n', field)
      end
      for _, operator in ipairs(native.operators) do
        write('  %s\n', operator)
      end

      -- The method form of each library function, which the runtime carries
      -- too: `vector.normalize(v)` is also `v:normalize()`. The receiver is the
      -- first argument, so it becomes `self`.
      for _, fn in ipairs(module.functions) do
        for _, variant in ipairs(fn.variants) do
          if variant.arguments and #variant.arguments > 0 then
            local rest = {}
            for index = 2, #variant.arguments do
              table.insert(rest, variant.arguments[index])
            end
            write('%s\n', genMethod(fn, { arguments = rest, returns = variant.returns }))
          end
        end
      end

      write('end\n')
      -- Callable as well as indexable: `vector(x, y, z)` is documented as a
      -- synonym for `vector.pack(x, y, z)`, and the same holds for
      -- `quaternion`. A table type alone cannot say so, so the declaration is
      -- the module intersected with what calling it answers.
      local pack = nil
      for _, fn in ipairs(module.functions) do
        if fn.name == 'pack' then
          pack = fn
        end
      end

      write('\ndeclare %s: %sModule', module.name, module.name:gsub('^%l', string.upper))

      if pack then
        for _, variant in ipairs(pack.variants) do
          write('\n  & (%s)', genFunctionType(variant))
        end
      end

      write('\n')
    end
  end

  local file = assert(io.open(directory .. '/lovr.d.luau', 'w'))
  file:write(table.concat(out):sub(1, -2))
  file:close()
end
