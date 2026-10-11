return {
  tag = 'graphics-global',
  summary = 'Check if graphics is initialized.',
  description = 'Returns whether graphics is initialized.',
  arguments = {},
  returns = {
    initialized = { type = 'boolean', description = 'Whether graphics is initialized.' }
  },
  variants = {
    { arguments = {}, returns = { 'initialized' } }
  },
  related = { 'lovr.graphics.initialize' }
}
