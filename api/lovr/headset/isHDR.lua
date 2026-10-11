return {
  tag = 'headset',
  summary = 'Check if the headset uses HDR rendering.',
  description = 'Returns whether the headset uses HDR rendering.',
  arguments = {},
  returns = {
    hdr = { type = 'boolean', description = 'Whether the headset uses HDR rendering.' }
  },
  variants = {
    { arguments = {}, returns = { 'hdr' } }
  }
}
