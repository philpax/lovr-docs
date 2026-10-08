-- Regressions for the Luau generator's configuration and structured table types.
-- Run from the repository root with LÖVR checked out beside it: lua tests/luau.lua

local bootFile = assert(io.open('../lovr/etc/boot.lua', 'r'))
local boot = bootFile:read('*a')
bootFile:close()
local defaults = assert(boot:match('local conf = (.-)\n\nfunction lovr.boot'))
local runtimeConf = assert((loadstring or load)('return ' .. defaults))()
local conf = dofile('api/lovr/callbacks/conf.lua')
local api = dofile('api/init.lua')
conf.arguments.t.name = 't'

-- api/init.lua is a prebuilt aggregate; the configuration under test is the source metadata.
for _, callback in ipairs(api.callbacks) do
  if callback.name == 'conf' then
    callback.variants = { { arguments = { conf.arguments.t }, returns = {} } }
  end
end

local output
lovr = {
  filesystem = { getSource = function() return '/metadata-test' end },
  system = { getOS = function() return 'Linux' end }
}
os.execute = function() return true end
io.open = function(path, mode)
  assert(path == '/metadata-test/luau/lovr.d.luau' and mode == 'w')
  return { write = function(_, content) output = content end, close = function() end }
end

local generate = dofile('api/generators/luau.lua')
local function has(text) assert(output:find(text, 1, true), 'missing from output: ' .. text) end

generate(api)
has('export type LovrConfiguration = {')
has('conf: ((t: LovrConfiguration) -> ())?')
has('task: boolean')
has('samplerate: number?')
has('headset: { backend: "auto" | "openxr" | "openvr", connect: boolean')
has('read supersample: boolean, write supersample: boolean | number | nil')
has('read overlay: boolean, write overlay: boolean | number')
has('extensions: {string}?')
has('icon: string | Blob | Image | nil')
assert(not output:find('[].', 1, true), 'element notation leaked into a field name')

-- Every documented field has a runtime default and the example sets it, and nothing is undocumented.
local t = { modules = {}, audio = { reverb = {} }, graphics = {}, headset = {}, math = {}, thread = {}, window = {} }
local runtime = lovr
local example = assert((loadstring or load)('lovr = {}; ' .. conf.example.code .. '; return lovr.conf'))()
example(t)
lovr = runtime
assert(t.headset.backend == 'openxr')
local function nullable(field)
  local type = field.type .. '|' .. (field.writeType or '')
  return type:find('?', 1, true) or type:find('nil', 1, true)
end
local function audit(fields, actual, set)
  local known = {}
  for _, field in ipairs(fields) do
    known[field.name] = true
    local value = actual[field.name]
    assert(value ~= nil or nullable(field), 'missing runtime default: ' .. field.name)
    assert(set[field.name] == value or field.table, 'example default mismatch: ' .. field.name)
    if field.table then
      assert(type(value) == 'table', 'runtime default is not a table: ' .. field.name)
      audit(field.table, value, set[field.name])
    end
  end
  for name in pairs(actual) do assert(known[name], 'undocumented runtime default: ' .. name) end
  for name in pairs(set) do assert(known[name], 'undocumented example field: ' .. name) end
end
audit(conf.arguments.t.table, runtimeConf, t)

local function generateShape(argument, returns)
  api.callbacks = {
    { name = 'shape', variants = { { arguments = { argument }, returns = returns or {} } } }
  }
  generate(api)
end

-- Fields named `[].name` describe the elements of an array, and `[][n]` their positions.
generateShape({ name = 'devices', type = 'table', table = {
  { name = '[].id', type = 'userdata' }, { name = '[].name', type = 'string' }
} }, { { name = 'formats', type = 'table', table = {
  { name = '[][1]', type = 'string' }, { name = '[][2]', type = 'number' }, { name = '[][3]', type = 'number' }
} } })
has('shape: ((devices: { read [number]: { read id: userdata, read name: string } }) -> {{string | number}})?')

-- Choices are quoted so that any string survives.
local choices = { 'quote"', 'slash\\', 'line\nfeed' }
generateShape({ name = 't', type = 'table', table = {
  { name = 'empty', type = 'table', table = {} },
  { name = 'choice', type = 'string', values = choices }
} })
has('read empty: {  }')
local encoded = assert(output:match('read choice: (.-) }'))
local decoded = { assert((loadstring or load)('return ' .. encoded:gsub(' | ', ', ')))() }
assert(#decoded == #choices)
for index, value in ipairs(choices) do assert(decoded[index] == value) end

-- Metadata the generator cannot describe faithfully is an error, not a silently wrong type.
local invalid = {
  { name = 'bad', type = 'table', table = { hidden = { name = 'lost', type = 'number' } } },
  { name = 'bad', type = 'table', table = { [2] = { name = 'lost', type = 'number' } } },
  { name = 'bad', type = 'table', table = { { name = '', type = 'string' } } },
  { name = 'bad', type = 'table', table = { { name = 'untyped' } } },
  { name = 'bad', type = 'table', table = {
    { name = 'duplicate', type = 'number' }, { name = 'duplicate', type = 'string' }
  } },
  { name = 'bad', type = 'table', table = { { name = '[].element', type = 'number' }, { name = 'own', type = 'number' } } },
  { name = 'bad', type = 'number', table = {} },
  { name = 'bad', type = 'string', values = {} },
  { name = 'bad', type = 'string', values = { 'auto', hidden = 'lost' } },
  { name = 'bad', type = 'string', values = { 'auto', 1 } }
}
for _, shape in ipairs(invalid) do
  local ok, message = pcall(generateShape, { name = 't', type = 'table', table = {
    { name = 'nested', type = 'table', table = { shape } }
  } })
  assert(not ok, 'accepted invalid metadata')
  assert(tostring(message):find('luau generator:', 1, true), tostring(message))
end
print('Luau generator regressions passed.')
