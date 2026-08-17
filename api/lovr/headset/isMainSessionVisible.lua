return {
  tag = 'headset-misc',
  summary = 'Check if another application is presenting.',
  description = [[
    Returns whether an application other than this one is presenting to the headset.

    Only an overlay session is told this.  An overlay shares the runtime with whatever holds the
    primary session, and the runtime reports when that session's visibility changes.  A session that
    did not ask to be an overlay, through `t.headset.overlay` in `lovr.conf`, always reads false.
  ]],
  arguments = {},
  returns = {
    visible = {
      type = 'boolean',
      description = 'Whether another application is presenting.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'visible' }
    }
  },
  notes = [[
    An overlay that draws a background of its own uses this to decide whether to draw it.  Drawn
    while another application is presenting, an opaque background covers that application's frame.

    False is also the answer on a runtime that never reports the state, which is why it is the
    assumption rather than an unknown: an overlay with nothing behind it is the case that wants a
    background, and drawing one there is the harmless direction to be wrong in.
  ]],
  related = {
    'lovr.headset.isVisible',
    'lovr.headset.isActive'
  }
}
