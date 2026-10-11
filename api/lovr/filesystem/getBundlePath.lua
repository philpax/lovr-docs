return {
  tag = 'filesystem-paths',
  summary = 'Get the bundled project path.',
  description = 'Returns the path to the bundled project and its root within the bundle.',
  arguments = {},
  returns = {
    path = { type = 'string?', description = 'The bundle path, or nil if there is no bundled project.' },
    root = { type = 'string?', description = 'The project root within the bundle, or nil if there is no bundled project.' }
  },
  variants = {
    { arguments = {}, returns = { 'path', 'root' } }
  }
}
