return {
  tag = 'headset-misc',
  summary = 'Check if content is being shown in the headset display.',
  description = [[
    Returns whether LÖVR's content is being presented to the headset display, and whether the main
    application session is visible.  Normally both are true, but VR runtimes may hide or minimize
    either session.
  ]],
  arguments = {},
  returns = {
    visible = {
      type = 'boolean',
      description = 'Whether this application is visible.'
    },
    main = {
      type = 'boolean',
      description = 'Whether the main headset session is visible.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'visible', 'main' }
    }
  },
  notes = [[
    `lovr.draw` may still be called even when the application is invisible, and apps should continue
    to render the scene normally because the VR system may use this for timing info.  If the VR
    system decides that the application no longer needs to render, LÖVR will stop calling
    `lovr.draw`.
  ]],
  related = {
    'lovr.visible',
    'lovr.headset.isFocused',
    'lovr.focus'
  }
}
