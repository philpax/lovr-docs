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

local function genType(info)
  local types = {}

  for t in info.type:gmatch('[%w{}%*%.]+') do
    if t == 'function' then
      table.insert(types, genFunctionType(info))
    elseif t == '*' then
      table.insert(types, 'any')
    elseif t == 'table' then
      table.insert(types, '{}')
    else
      table.insert(types, t)
    end
  end

  if #types == 1 then
    return types[1]
  else
    return table.concat(types, ' | ') .. (info.default and ' | nil' or '')
  end
end

local function genArguments(arguments, ismethod)
  local t = {}

  for _, arg in ipairs(arguments) do
    local name, type = arg.name, genType(arg)

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
    table.insert(t, genType(ret))
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

  local function writeFunction(fn)
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
      write('type %s =\n', enum.name)
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
      write('type %sModule = {\n', module.name:gsub('^%l', string.upper))

      for _, fn in ipairs(module.functions) do
        writeFunction(fn)
      end

      write('}\n\n')
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

  for _, callback in ipairs(api.callbacks) do
    writeFunction(callback)
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
      write('\ndeclare %s: %sModule\n', module.name, module.name:gsub('^%l', string.upper))
    end
  end

  local file = assert(io.open(directory .. '/lovr.d.luau', 'w'))
  file:write(table.concat(out):sub(1, -2))
  file:close()
end
