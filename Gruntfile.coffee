module.exports = (grunt) ->

  appPath = "app"
  vendorPath = appPath + "/vendor/"
  assetsPath =  appPath + "/assets/"

  server =
    hostname: "localhost"
    port: 9000

  ###
  CSS files to inject in order
  (uses Grunt-style wildcard/glob/splat expressions)
  ###
  cssVendorFilesToInject = [
    "**/*.css"
  ].map (path) ->
    vendorPath + path

  cssAssetsFilesToInject = [
    "css/print.css"
    "css/reset.css"
    "css/style.css"
    "**/*.css"
  ].map (path) ->
    assetsPath + path

  ###
  Javascript files to inject in order
  (uses Grunt-style wildcard/glob/splat expressions)
  ###
  jsVendorFilesToInject = [
    "modernizr/**/*.js"
    "jquery/**/*.js"
    "**/*.js"
  ].map (path) ->
    vendorPath + path

  jsAssetsFilesToInject = [
    "js/main.js"
    "**/*.js"
  ].map (path) ->
    assetsPath + path

  folderMount = (connect, base) ->
    # Serve static files.
    connect.static ( require("path").resolve base )

  ####################
  ## grunt config
  ####################
  grunt.initConfig

    connect:
      options:
        port: server.port
        hostname: server.hostname

      dev:
        options:
          keepalive: true
          middleware: (connect, options) ->
            [
              folderMount(connect, appPath)
            ]
          open:
            target: "http://" + server.hostname + ":" + server.port
          livereload: true

    "sails-linker":
      devVendorJs:
        options:
          startTag: "<!--VENDOR_SCRIPTS-->"
          endTag: "<!--VENDOR_SCRIPTS END-->"
          fileTmpl: "<script src=\"%s\"></script>"
          appRoot: appPath
        # jsVendorFilesToInject defined up top
        files:
          "app/**/*.html": jsVendorFilesToInject

      devAssetsJs:
        options:
          startTag: "<!--ASSETS_SCRIPTS-->"
          endTag: "<!--ASSETS_SCRIPTS END-->"
          fileTmpl: "<script src=\"%s\"></script>"
          appRoot: appPath
        # jsAssetsFilesToInject defined up top
        files:
          "app/**/*.html": jsAssetsFilesToInject

      devVendorStyles:
        options:
          startTag: "<!--VENDOR_STYLES-->"
          endTag: "<!--VENDOR_STYLES END-->"
          fileTmpl: "<link rel=\"stylesheet\" href=\"%s\">"
          appRoot: appPath
        # cssVendorFilesToInject defined up top
        files:
          "app/**/*.html": cssVendorFilesToInject

      devAssetsStyles:
        options:
          startTag: "<!--ASSETS_STYLES-->"
          endTag: "<!--ASSETS_STYLES END-->"
          fileTmpl: "<link rel=\"stylesheet\" href=\"%s\">"
          appRoot: appPath
        # cssAssetsFilesToInject defined up top
        files:
          "app/**/*.html": cssAssetsFilesToInject

    # Bower Task
    bwr: grunt.file.readJSON(".bowerrc")
    bower:
      options:
        targetDir: vendorPath
        layout: "byComponent"
        verbose: false
        install: true
        cleanTargetDir: true
        bowerOptions: {}
      install:
        cleanBowerDir: false
      dev:
        options:
#          install: false
          cleanBowerDir: false
      prod: {}

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  # vendor files in use bower
  grunt.registerTask "linkDevVendor", ["sails-linker:devVendorJs", "sails-linker:devVendorStyles"]
  grunt.registerTask "linkDevAssets", ["sails-linker:devAssetsJs", "sails-linker:devAssetsStyles"]

  grunt.registerTask "default", ["bower:dev", "linkDevVendor", "linkDevAssets", "connect:dev"]
