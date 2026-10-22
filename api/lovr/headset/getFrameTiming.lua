return {
  tag = 'headset-misc',
  summary = 'Get the pacing of the latest frame.',
  description = [[
    Returns the pacing of the latest headset frame, and the compositor's own timing where the runtime
    reports it.  Times are in seconds.
  ]],
  arguments = {},
  returns = {
    timing = {
      type = 'table?',
      description = 'The frame timing, or `nil` when the backend has no timing for the latest frame.',
      table = {
        { name = 'interval', type = 'number', description = 'The time between the starts of the last two frames.' },
        { name = 'work', type = 'number', description = 'The time the previous frame took from its start to its submission.' },
        { name = 'prediction', type = 'number', description = 'The time from the latest frame\'s start to its predicted display.' },
        {
          name = 'skipped',
          type = 'number',
          description = 'The display refreshes that showed the previous frame again before this one, which is zero when the frame is on time.'
        },
        {
          name = 'compositor',
          type = 'table?',
          description = 'The compositor\'s most recent frame, present only where the runtime reports it.',
          table = {
            { name = 'frame', type = 'number', description = 'The compositor frame index.' },
            { name = 'gpu', type = 'number', description = 'The compositor\'s GPU time for the frame.' },
            { name = 'cpu', type = 'number', description = 'The compositor\'s CPU time for the frame.' },
            { name = 'presents', type = 'number', description = 'How many times the frame was presented.' },
            { name = 'mispresented', type = 'number', description = 'How many times the frame was presented on an unintended refresh.' },
            { name = 'dropped', type = 'number', description = 'How many additional refreshes repeated the previous frame.' },
            { name = 'reprojecting', type = 'boolean', description = 'Whether the compositor reprojected the frame because the application was late.' }
          }
        }
      }
    }
  },
  variants = {
    { arguments = {}, returns = { 'timing' } }
  },
  notes = 'Only the OpenVR backend reports frame timing.',
  related = { 'lovr.headset.getDeltaTime', 'lovr.graphics.getTiming' }
}
