parallel = require("concurrent-transform")
os       = require("os")

module.exports = parallelize = (transform, concurrency = os.cpus().length) ->

  return parallel(transform, concurrency)