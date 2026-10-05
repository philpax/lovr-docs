return {
  tag = 'callbacks',
  summary = 'Called when a key is released.',
  description = 'This callback is called when a key is released.',
  arguments = {
    key = {
      type = 'KeyCode',
      description = 'The key that was released.'
    },
    scancode = {
      type = 'number',
      description = 'The id of the key (ignores keyboard layout, may vary between keyboards).'
    },
    modifiers = {
      type = 'table?',
      mutable = false,
      description = 'The modifier snapshot for this event, or nil when unavailable.',
      table = {
        {
          name = 'shift',
          type = 'boolean',
          description = 'Whether Shift is active.'
        },
        {
          name = 'control',
          type = 'boolean',
          description = 'Whether Control is active.'
        },
        {
          name = 'alt',
          type = 'boolean',
          description = 'Whether Alt is active.'
        },
        {
          name = 'super',
          type = 'boolean',
          description = 'Whether Super (the Windows or Command key) is active.'
        },
        {
          name = 'capsLock',
          type = 'boolean',
          description = 'Whether Caps Lock is active.'
        },
        {
          name = 'numLock',
          type = 'boolean',
          description = 'Whether Num Lock is active.'
        }
      }
    }
  },
  returns = {},
  variants = {
    {
      arguments = { 'key', 'scancode', 'modifiers' },
      returns = {}
    }
  },
  notes = [[
    `modifiers` is a snapshot captured with the key event.  The GLFW backend includes the host's Caps Lock and Num Lock flags by enabling `GLFW_LOCK_KEY_MODS`.  Other backends currently return nil.  Nil means that the snapshot is unavailable, not that every modifier is inactive.  When the table is present, every field is a boolean.  It is frozen in Luau and a plain table in Lua and LuaJIT.  Later key events do not change it.

    This snapshot does not resolve a layout-dependent key symbol or describe arbitrary keyboard remapping.  The key and scancode arguments are unchanged.  `lovr.textinput` remains the callback for text.
  ]],
  related = {
    'lovr.system.wasKeyReleased',
    'lovr.keypressed',
    'lovr.textinput',
    'lovr.system.isKeyDown'
  }
}
