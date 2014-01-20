http   = require 'http'
sockjs = require 'sockjs'
Jandal = require 'jandal'

Jandal.handle 'node'

class Socket

  constructor: (@socket) ->
    @socket.namespace('time').on('get', @getTime)

  getTime: (fn) ->
    fn Date.now()

server = http.createServer()

conn = sockjs.createServer()
conn.installHandlers server, prefix: '/socket'

conn.on 'connection', (socket) ->
  jandal = new Jandal(socket)
  new Socket(jandal)

server.listen 3000
