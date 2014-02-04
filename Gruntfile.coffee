module.exports = (grunt) ->

  # Listen on port 35729
  LIVERELOAD_PORT = 35729

  appPath = "app/"
  vendorPath = appPath + "vendor/"
  assetsPath =  appPath + "assets/linker/"

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
    "css/reset.css"
    "**/*.css"
    "css/style.css"
  ].map (path) ->
    assetsPath + path

#    reg = /^!(.*)/ig;
#    result = reg.exec(path)
#    return assetsPath + path
#
#    if( result )
#      console.log("!" + assetsPath + result[1])
#      return "!" + assetsPath + result[1]
#    else
#      console.log(assetsPath + path)
#      return assetsPath + path

  ###
  Javascript files to inject in order
  (uses Grunt-style wildcard/glob/splat expressions)
  ###
  jsVendorFilesToInject = [
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

    watch:
      linker:
        files: Array.prototype.concat(jsVendorFilesToInject,jsAssetsFilesToInject,cssVendorFilesToInject,cssAssetsFilesToInject)
        tasks: ["linkDev"]
        options:
          livereload: false

      static:
        files: [ "!" + vendorPath, "!" + assetsPath, appPath + "**/*" ]
        options:
          livereload: LIVERELOAD_PORT

    connect:
      options:
        port: server.port
        hostname: server.hostname

      dev:
        options:
          keepalive: false
          middleware: (connect, options) ->
            [
              folderMount(connect, appPath)
            ]
          open:
            target: "http://" + server.hostname + ":" + server.port
          livereload: true

  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks);

  # vendor files in use bower
  grunt.registerTask "linkDevVendor", ["sails-linker:devVendorJs", "sails-linker:devVendorStyles"]
  grunt.registerTask "linkDevAssets", ["sails-linker:devAssetsJs", "sails-linker:devAssetsStyles"]
  grunt.registerTask "linkDev", ["linkDevVendor", "linkDevAssets"]


  grunt.registerTask "default", ["bower:dev", "linkDev", "connect:dev", "watch"]

