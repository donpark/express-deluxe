url = require('url')

express = require("express")
RedisStore = require('connect-redis')(express)

default_ports = 'http:': 80, 'https:': 443
app_url = url.parse '{{application_url}}'
app_port = app_url.port or default_ports[app_url.protocol]

config =
  title: "{{application_title}}"
  port: app_port

app = module.exports = express.createServer()
app.configure ->
  app.set "views", __dirname + "/views"
  app.set "view engine", "jade"
  app.use express.cookieParser()
  app.use express.session
    store: new RedisStore()
    secret: '{{session_store_secret}}'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static(__dirname + "/public")

app.configure "development", ->
  app.use express.errorHandler
    dumpExceptions: true
    showStack: true

app.configure "production", ->
  app.use express.errorHandler()

# routes
require("./routes/default").configure app, config

# websocket
io = require('socket.io').listen app
io.sockets.on 'connection', (socket) ->
  socket.emit 'news',
    hello: 'world'
  socket.on 'my other event', (data) ->
    console.dir data

# listen
app.listen config.port
console.log "{{application_title}} server listening on port %d in %s mode", app.address().port, app.settings.env
