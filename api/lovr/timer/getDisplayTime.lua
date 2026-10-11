return {
  summary = 'Get the time used for frame display.',
  description = 'Returns the predicted headset display time when available, or the current timer time otherwise.',
  arguments = {},
  returns = {
    time = { type = 'number', description = 'The display time, in seconds.' }
  },
  variants = {
    { arguments = {}, returns = { 'time' } }
  },
  related = { 'lovr.timer.getTime' }
}
