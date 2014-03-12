// Generated by CoffeeScript 1.7.1
(function() {
  var buildAndWatch, clone, connect, duplexer, eventStream, fork, gulp, handleError, http, logger, merge, multipipe, os, parallel, parallelize, path, plumber, server, through, util, watch,
    __slice = [].slice;

  gulp = require("gulp");

  eventStream = require("event-stream");

  util = require("gulp-util");

  plumber = require("gulp-plumber");

  watch = require("gulp-watch");

  through = require("through2");

  duplexer = require("duplexer2");

  multipipe = require("multipipe");

  parallel = require("concurrent-transform");

  merge = require("multistream-merge");

  connect = require("connect");

  os = require("os");

  path = require("path");

  http = require("http");

  handleError = function(err) {
    util.log(util.colors.red("⚠"), err, err.stack);
    return util.beep();
  };

  logger = function() {
    return through.obj(function(file, enc, done) {
      util.log(">>", util.colors.yellow(path.relative(process.cwd(), file.path)));
      done(null, file);
    });
  };

  clone = function() {
    return through.obj(function(file, enc, done) {
      return done(null, file.clone());
    });
  };

  fork = function() {
    var input, streams;
    streams = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    input = through.obj();
    streams.forEach(function(stream) {
      return input.pipe(clone()).pipe(stream);
    });
    return duplexer(input, merge.obj.apply(merge, streams));
  };

  parallelize = function(transform, concurrency) {
    if (concurrency == null) {
      concurrency = os.cpus().length;
    }
    return parallel(transform, concurrency);
  };

  server = function(dir, port) {
    return http.createServer(connect().use(connect["static"](dir))).listen(port);
  };

  buildAndWatch = function(key, src, dest, options, streamMaker) {
    if (arguments.length === 4) {
      streamMaker = options;
      options = {};
    }
    if (key == null) {
      throw new Error("No task key given.");
    }
    if (src == null) {
      throw new Error("No source path given.");
    }
    if (dest == null) {
      throw new Error("No destination path given.");
    }
    if (options.emitOnGlob == null) {
      options.emitOnGlob = true;
    }
    if (options.singleFile == null) {
      options.singleFile = false;
    }
    if (options.newer == null) {
      options.newer = false;
    }
    gulp.task("build:" + key, function() {
      var stream;
      stream = streamMaker();
      stream.on("error", handleError);
      return gulp.src(src).pipe(logger()).pipe(plumber()).pipe(stream).pipe(gulp.dest(dest)).pipe(logger());
    });
    return gulp.task("watch:" + key, function() {
      var stream, _ref, _ref1;
      stream = streamMaker();
      stream.on("error", handleError);
      if (options.singleFile) {
        if (options.emitOnGlob) {
          gulp.src(src).pipe(plumber()).pipe(stream).pipe(gulp.dest(dest)).pipe(logger());
        }
        return watch({
          glob: (_ref = options.watchSrc) != null ? _ref : src,
          emitOnGlob: false,
          name: "" + key + "-watcher"
        }, function() {
          return gulp.src(src).pipe(plumber()).pipe(stream).pipe(gulp.dest(dest)).pipe(logger());
        });
      } else {
        return watch({
          glob: (_ref1 = options.watchSrc) != null ? _ref1 : src,
          emitOnGlob: options.emitOnGlob,
          name: "" + key + "-watcher"
        }).pipe(plumber()).pipe(stream).pipe(gulp.dest(dest)).pipe(logger());
      }
    });
  };

  module.exports = {
    handleError: handleError,
    buildAndWatch: buildAndWatch,
    server: server,
    logger: logger,
    clone: clone,
    fork: fork,
    parallelize: parallelize,
    pipe: multipipe
  };

}).call(this);
