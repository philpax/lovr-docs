return {
  tag = 'callbacks',
  summary = 'Initialize the project and return its frame loop.',
  description = 'Initializes the project and returns the function called each frame by the main coroutine.',
  arguments = {},
  returns = {
    loop = {
      type = 'function',
      arguments = {},
      returns = {
        { name = 'result', type = 'number | "restart" | nil' },
        { name = 'cookie', type = '*', description = 'The value returned by lovr.restart, when restarting.' }
      },
      description = 'The frame loop, which returns nil to continue, an exit code to quit, or restart and a restart value.'
    }
  },
  variants = {
    { arguments = {}, returns = { 'loop' } }
  },
  related = { 'lovr.run', 'lovr.restart' }
}
