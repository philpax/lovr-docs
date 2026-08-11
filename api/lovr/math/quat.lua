return {
  tag = 'vectors',
  deprecated = true,
  summary = 'Create a quaternion.',
  description = 'This is a deprecated alias for `quaternion.angleaxis`.',
  arguments = {},
  returns = {
    q = {
      type = 'quaternion',
      description = 'The new quaternion.'
    }
  },
  variants = {
    {
      arguments = {},
      returns = { 'q' }
    }
  }
}
