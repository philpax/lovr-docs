return {
  summary = 'Compression formats.',
  description = 'The compression formats supported by `lovr.data.compress` and `lovr.data.decompress`.',
  values = {
    { name = 'deflate', description = 'Raw DEFLATE data without a wrapper.' },
    { name = 'zlib', description = 'DEFLATE data with a zlib wrapper.' },
    { name = 'gzip', description = 'DEFLATE data with a gzip wrapper.' }
  }
}
