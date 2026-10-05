return {
  tag = 'callbacks',
  summary = 'Called when a key is pressed.',
  description = 'This callback is called when a key is pressed.',
  arguments = {
    key = {
      type = 'KeyCode',
      description = 'The key that was pressed.'
    },
    scancode = {
      type = 'number',
      description = 'The id of the key (ignores keyboard layout, may vary between keyboards).'
    },
    isrepeat = {
      type = 'boolean',
      description = 'Whether the event is the result of a key repeat instead of an actual press.'
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
      arguments = { 'key', 'scancode', 'isrepeat', 'modifiers' },
      returns = {}
    }
  },
  notes = [[
    By default this will be fired only once while a key is held down. This can be changed to fire
    multiple times by setting `lovr.system.setKeyRepeat` to true. In that case `isrepeat` will become
    true whenever the event is the result of a key repeat and false on a single press.

    `modifiers` is a snapshot captured with the key event.  The GLFW backend includes the host's Caps Lock and Num Lock flags by enabling `GLFW_LOCK_KEY_MODS`.  Other backends currently return nil.  Nil means that the snapshot is unavailable, not that every modifier is inactive.  When the table is present, every field is a boolean.  It is frozen in Luau and a plain table in Lua and LuaJIT.  Later key events do not change it.

    This snapshot does not resolve a layout-dependent key symbol or describe arbitrary keyboard remapping.  The key and scancode arguments are unchanged.  `lovr.textinput` remains the callback for text.
  ]],
  related = {
    'lovr.system.wasKeyPressed',
    'lovr.keyreleased',
    'lovr.textinput',
    'lovr.system.isKeyDown'
  }
}
