require './vendor/sockjs'
Jandal = require 'jandal/build/client'

Jandal.handle 'sockjs'

conn = new SockJS('http://192.168.0.100:3000/socket')
socket = new Jandal(conn)

scriptLoadTime = Date.now()

offset = 0
target = null

ServerDate = -> ServerDate.toString()
ServerDate.parse = Date.parse
ServerDate.UTC = Date.UTC
ServerDate.now = -> Date.now() + offset

for method in ["toString", "toDateString", "toTimeString", "toLocaleString",
    "toLocaleDateString", "toLocaleTimeString", "valueOf", "getTime",
    "getFullYear", "getUTCFullYear", "getMonth", "getUTCMonth", "getDate",
    "getUTCDate", "getDay", "getUTCDay", "getHours", "getUTCHours",
    "getMinutes", "getUTCMinutes", "getSeconds", "getUTCSeconds",
    "getMilliseconds", "getUTCMilliseconds", "getTimezoneOffset", "toUTCString",
    "toISOString", "toJSON"]
  ServerDate[method] = ->
    new Date(ServerDate.now())[method]()

ServerDate.getPrecision = ->
  return unless target.precision?
  return target.precision + Math.abs(target - offset)

ServerDate.amortizationRate = 25
ServerDate.amortizationThreshold = 2000

Object.defineProperty ServerDate, 'synchronizationIntervalDelay',
  get: -> return synchronizationIntervalDelay
  set: (value) ->
    synchronizationIntervalDelay = value
    clearInterval synchronizationInterval
    synchronizationInterval  = setInterval synchronize, value

# Every hour synchronize the clocks
ServerDate.synchronizationIntervalDelay = 60 * 60 * 1000

class Offset
  constructor: (@value, @precision) ->
  valueOf: => @value
  toString: => "#{ @value } +/- #{ @precision }ms"

setTarget = (target) ->
  delta = Math.abs(target - offset)
  if delta > ServerDate.amortizationThreshold
    offset = target



synchronize = ->

  iteration = 1
  best = null
  requestTime = 0
  responseTime = 0

  requestSample = ->
    requestTime = Date.now()
    socket.emit 'time.get', (response) ->
      responseTime = Date.now()
      processSample(response)

  processSample = (serverNow) ->

    precision = (responseTime - requestTime) / 2
    value = serverNow + precision - responseTime

    sample = new Offset(value, precision)

    console.log sample.toString()

    if iteration is 1 or sample.precision <= best.precision
      best = sample

    # Take 10 samples so we get a good chance of at least one sample with
    # low latency

    if iteration < 10
      iteration++
      requestSample()
    else
      setTarget best

  requestSample()



offset = Date.now() - scriptLoadTime
precision = (scriptLoadTime - performance.timing.domLoading) / 2
offset += precision

setTarget new Offset(offset, precision)

# Amortization process.
# Every second, adjust the offset toward the target by a small amount
setInterval ->
  delta = Math.max(-ServerDate.amortizationRate,
    Math.min(ServerDate.amortizationRate, target - offset))
  offset += delta
, 1000

conn.onopen = synchronize

window.ServerDate = ServerDate
