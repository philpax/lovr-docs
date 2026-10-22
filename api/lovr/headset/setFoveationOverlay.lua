return {
  tag = 'headset',
  summary = 'Show or hide the foveation overlay.',
  description = [[
    Tints each eye by its fragment density and marks the gaze point, so the areas that foveation
    renders at reduced density are visible.  The tint appears only while foveation is active.
  ]],
  arguments = {
    enabled = { type = 'boolean', description = 'Whether to show the foveation overlay.' }
  },
  returns = {
    success = { type = 'boolean', description = 'Whether the overlay setting was applied.' }
  },
  variants = {
    { arguments = { 'enabled' }, returns = { 'success' } }
  },
  notes = 'Only the OpenVR backend draws the overlay.  Enabling it fails where foveation is unsupported.',
  related = { 'lovr.headset.getFoveationOverlay', 'lovr.headset.setFoveation' }
}
