connect     = require("connect")
serveStatic = require("serve-static")

module.exports = server = (dir, port) ->

  return connect()
    .use(serveStatic(dir))
    .listen(port)