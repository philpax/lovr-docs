return {
  tag = 'input',
  summary = 'Get the position of a hand pose.',
  description = 'Returns the position of a hand pose, or zeroes if the pose is not tracked.',
  arguments = {
    hand = { type = 'string', values = { 'left', 'right' }, description = 'The hand to query.' },
    pose = { type = 'HandPose', default = "'grip'", description = 'The hand pose to query.' }
  },
  returns = {
    x = { type = 'number', description = 'The x position, in meters.' },
    y = { type = 'number', description = 'The y position, in meters.' },
    z = { type = 'number', description = 'The z position, in meters.' }
  },
  variants = {
    { arguments = { 'hand', 'pose' }, returns = { 'x', 'y', 'z' } }
  },
  related = { 'lovr.headset.getHandPose', 'lovr.headset.getHandOrientation', 'HandPose' }
}
