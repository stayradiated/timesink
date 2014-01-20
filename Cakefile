Scrunch = require 'coffee-scrunch'
server  = require 'node-static'
http    = require 'http'
fs      = require 'fs'

# Configuration
config =
  port: 9294
  public: 'client'
  js:
    input:  'client/index.coffee'
    output: 'client/index.js'
    min:    'client/index.min.js'

# Options
option '-p', '--port [port]', 'Set port for cake server'
option '-w', '--watch', 'Watch the folder for changes'

compile =

  coffee: (options={}) ->

    scrunch = new Scrunch
      path: config.js.input
      compile: true
      verbose: true
      watch: options.watch

    scrunch.vent.on 'init', ->
      scrunch.scrunch()

    scrunch.vent.on 'scrunch', (data) ->
      console.log '[JS] Writing'
      fs.writeFile config.js.output, data

    scrunch.init()

# Tasks
task 'server', 'Start server', (options) ->

  # Compile files
  compile.coffee(options)

  # Start Server
  port = options.port or config.port
  file= new(server.Server)(config.public)
  server = http.createServer (req, res) ->
    req.addListener( 'end', ->
      file.serve(req, res)
    ).resume()
  server.listen(port)

  console.log 'Server started on ' + port

task 'build', 'Compile CoffeeScript', (options) ->
  compile.coffee(options)
