return {
  tag = 'headset',
  summary = 'Get whether the foveation overlay is shown.',
  description = 'Returns whether each eye is tinted by its fragment density, as set by `lovr.headset.setFoveationOverlay`.',
  arguments = {},
  returns = {
    enabled = { type = 'boolean', description = 'Whether the foveation overlay is shown.' }
  },
  variants = {
    { arguments = {}, returns = { 'enabled' } }
  },
  related = { 'lovr.headset.setFoveationOverlay', 'lovr.headset.setFoveation' }
}
