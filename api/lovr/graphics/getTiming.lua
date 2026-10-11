return {
  tag = 'graphics-misc',
  summary = 'Get GPU timing for submitted passes.',
  description = 'Returns GPU timing information keyed by Pass, or nil if timing information is unavailable.',
  arguments = {},
  returns = {
    timing = {
      type = 'table?',
      keyType = 'Pass',
      description = 'The timing information for each Pass.',
      table = {
        { name = '[].duration', type = 'number', description = 'The GPU duration of the pass, in seconds.' },
        { name = '[].submit', type = 'number', description = 'The CPU time spent submitting the pass, in seconds.' },
        { name = '[].start', type = 'number?', description = 'The GPU start time, in seconds, if supported.' },
        { name = '[].finish', type = 'number?', description = 'The GPU finish time, in seconds, if supported.' }
      }
    }
  },
  variants = {
    { arguments = {}, returns = { 'timing' } }
  },
  related = { 'lovr.graphics.setTimingEnabled', 'lovr.graphics.submit' }
}
