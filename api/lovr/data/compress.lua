return {
  summary = 'Compress a string or Blob.',
  description = 'Compresses data, returning a string for string input or a Blob for Blob input.',
  arguments = {
    string = { type = 'string', description = 'The data to compress.' },
    blob = { type = 'Blob', description = 'The data to compress.' },
    method = { type = 'CompressionMethod', default = "'deflate'", description = 'The compression format.' },
    level = { type = 'number', default = 'nil', description = 'The compression level, clamped to 0 through 8, or nil for the default level of 5.' }
  },
  returns = {
    string = { type = 'string', description = 'The compressed data.' },
    blob = { type = 'Blob', description = 'The compressed data.' }
  },
  variants = {
    { arguments = { 'string', 'method', 'level' }, returns = { 'string' } },
    { arguments = { 'blob', 'method', 'level' }, returns = { 'blob' } }
  },
  related = { 'lovr.data.decompress', 'CompressionMethod' }
}
