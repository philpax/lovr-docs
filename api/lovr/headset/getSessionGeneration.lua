return {
  tag = 'headset-misc',
  summary = 'Get the headset session generation.',
  description = 'Returns the session generation counter, which changes when the headset backend recreates its session.',
  arguments = {},
  returns = {
    generation = { type = 'number', description = 'The session generation counter.' }
  },
  variants = {
    { arguments = {}, returns = { 'generation' } }
  }
}
