-- Regressions for native library metadata and callable math aliases.
-- Run from the repository root: lua tests/surface.lua.

local api = dofile('api/init.lua')
local added = {
  lovr = { 'boot' },
  data = { 'compress', 'decompress' },
  filesystem = { 'getBundlePath', 'setSource' },
  graphics = { 'getTiming', 'initialize', 'isInitialized' },
  headset = { 'getHandOrientation', 'getHandPose', 'getHandPosition', 'getLayerLimit', 'getSessionGeneration', 'isHDR' },
  system = { 'openConsole' },
  timer = { 'getDisplayTime' },
  vector = { 'abs', 'ceil', 'clamp', 'create', 'floor', 'magnitude', 'max', 'min', 'sign', 'rotate' },
  math = { 'newQuat', 'quat' }
}

local function sourceFunction(module, name)
  local path = module == 'lovr' and 'api/lovr/' or ('api/lovr/' .. module .. '/')
  local fn = dofile(path .. name .. '.lua')
  fn.name = name
  for _, variant in ipairs(fn.variants) do
    for index, argument in ipairs(variant.arguments) do
      variant.arguments[index] = assert(fn.arguments[argument])
      variant.arguments[index].name = argument
    end
    for index, result in ipairs(variant.returns) do
      variant.returns[index] = assert(fn.returns[result])
      variant.returns[index].name = result
    end
  end
  return fn
end

for _, module in ipairs(api.modules) do
  for _, name in ipairs(added[module.name] or {}) do
    local fn = sourceFunction(module.name, name)
    local replaced = false
    for index, old in ipairs(module.functions) do
      if old.name == name then module.functions[index], replaced = fn, true end
    end
    if not replaced then table.insert(module.functions, fn) end
  end
  if module.name == 'vector' or module.name == 'quaternion' then
    module.fields = dofile('api/lovr/' .. module.name .. '/init.lua').fields
  end
  local enumName = module.name == 'data' and 'CompressionMethod' or module.name == 'headset' and 'HandPose'
  if enumName then
    local enum = dofile('api/lovr/' .. module.name .. '/' .. enumName .. '.lua')
    enum.name = enumName
    table.insert(module.enums, enum)
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
has('export type CompressionMethod =\n  | "deflate"\n  | "zlib"\n  | "gzip"')
has('export type HandPose =\n  | "grip"\n  | "point"\n  | "pinch"\n  | "poke"\n  | "palm"')
has('compress:\n    & ((string: string, method: CompressionMethod?, level: number?) -> string)')
has('& ((blob: Blob, method: CompressionMethod?, level: number?) -> Blob),')
has('decompress:\n    & ((string: string, method: CompressionMethod?) -> string)')
has('& ((blob: Blob, method: CompressionMethod?) -> Blob),')
has('getBundlePath: () -> (string?, string?),')
has('setSource: (source: string) -> (),')
has('initialize: () -> (),')
has('isInitialized: () -> boolean,')
has('getTiming: () -> { [Pass]: { read duration: number, read submit: number, read start: number?, read finish: number? } }?,')
has('getHandPosition: (hand: "left" | "right", pose: HandPose?) -> (number, number, number),')
has('getHandOrientation: (hand: "left" | "right", pose: HandPose?) -> (number, number, number, number),')
has('getHandPose: (hand: "left" | "right", pose: HandPose?) -> (number, number, number, number, number, number, number),')
has('getLayerLimit: () -> number,')
has('getSessionGeneration: () -> number,')
has('isHDR: () -> boolean,')
has('openConsole: () -> (),')
has('getDisplayTime: () -> number,')
for _, name in ipairs({ 'abs', 'ceil', 'floor', 'sign' }) do
  has(name .. ': (v: vector) -> vector,')
  has('function ' .. name .. '(self): vector')
end
has('clamp: (v: vector, min: vector, max: vector) -> vector,')
has('create:\n    & ((x: number, y: number, z: number?) -> vector)')
has('magnitude: (v: vector) -> number,')
for _, name in ipairs({ 'max', 'min' }) do
  has(name .. ': (v: vector, ...vector) -> vector,')
  has('function ' .. name .. '(self, ...: vector): vector')
end
has('rotate: (v: vector, q: quaternion) -> vector,')
has('function rotate(self, q: quaternion): vector')
for _, name in ipairs({ 'back', 'backward', 'down', 'forward', 'left', 'one', 'right', 'up', 'zero' }) do
  has('  ' .. name .. ': vector,')
end
has('  identity: quaternion,')
for _, name in ipairs({ 'newVec2', 'newVec3', 'newVec4', 'vec2', 'vec3', 'vec4' }) do
  has('  ' .. name .. ': VectorModule\n    & ((x: number, y: number, z: number?) -> vector)')
end
for _, name in ipairs({ 'newQuat', 'quat' }) do
  has('  ' .. name .. ': QuaternionModule\n    & ((x: number, y: number, z: number, w: number) -> quaternion)\n    & (() -> quaternion),')
end
for _, name in ipairs({ 'Vec2', 'Vec3', 'Vec4', 'vec2', 'vec3', 'vec4' }) do
  has('declare ' .. name .. ': (VectorModule & ((x: number, y: number, z: number?) -> vector) & ((n: number) -> vector))?')
end
for _, name in ipairs({ 'Quat', 'quat' }) do
  has('declare ' .. name .. ': (QuaternionModule & ')
end
for _, name in ipairs({ 'Mat4', 'mat4' }) do
  local declaration = assert(output:match('declare ' .. name .. ': ([^\n]+)'))
  assert(declaration:find('((...number) -> Mat4)', 1, true), declaration)
  assert(declaration:sub(-1) == '?', declaration)
end
has('declare vector: VectorModule\n')
has('declare quaternion: QuaternionModule\n')
has('handlers: { [string]: ((...any) -> ...any)? },')
has('boot: () -> (() -> (number | "restart" | nil, any)),')

-- A keyed table cannot silently discard its key type or its element shape.
local graphics
for _, module in ipairs(api.modules) do
  if module.name == 'graphics' then graphics = module end
end
local invalid = sourceFunction('graphics', 'getTiming')
invalid.variants[1].returns[1].keyType = 1
table.insert(graphics.functions, invalid)
local ok, message = pcall(generate, api)
assert(not ok and tostring(message):find('table keys must have a string type', 1, true), tostring(message))
print('Native surface metadata regressions passed.')
