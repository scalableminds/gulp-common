util = require("gulp-util")

module.exports = handleError = (err) ->
  util.log(util.colors.red("⚠"), err, err.stack)
  util.beep()
