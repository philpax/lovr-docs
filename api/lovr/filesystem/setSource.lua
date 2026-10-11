return {
  tag = 'filesystem-paths',
  summary = 'Set the project source.',
  description = 'Sets the project source directory or archive.  Raises an error if the source cannot be set.',
  arguments = {
    source = { type = 'string', description = 'The source directory or archive path.' }
  },
  returns = {},
  variants = {
    { arguments = { 'source' }, returns = {} }
  },
  related = { 'lovr.filesystem.getSource' }
}
