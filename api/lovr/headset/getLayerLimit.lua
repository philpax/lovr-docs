return {
  tag = 'layers',
  summary = 'Get the composition layer limit.',
  description = 'Returns the maximum number of composition layers supported by the headset backend.',
  arguments = {},
  returns = {
    limit = { type = 'number', description = 'The maximum number of composition layers.' }
  },
  variants = {
    { arguments = {}, returns = { 'limit' } }
  }
}
