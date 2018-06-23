_ = require 'lodash'
url = require 'url'
WebSocket = require 'ws'

[clients, unsent, unread] = [{}, {}, {}]

wss = new WebSocket.Server
  port: 8080
  path: '/messaging'
  clientTracking: off
  maxPayload: 4 * 1024
  verifyClient: ({ req }) => req.cid = url.parse(req.url, yes)?.query?['client_id']

wss.on 'listening', => console.log "Listening on #{wss.options.port}"
wss.on 'error', console.error

wss.on 'connection', (ws, req) =>
  { cid } = req
  clients[cid] = ws
  # send if online
  if send = unsent[cid]
    ws.send JSON.stringify({ messages: _.values send }), =>
      unread[cid] = _.assign {}, unread[cid], unsent[cid]
      delete unsent[cid]

  ws.on 'close', => delete clients[cid]

  ws.on 'message', (data) =>
    try
      { send, read } = JSON.parse data
      return if not _.isArray(send) or not _.isArray(read)
    catch error then return console.error error

    # clean up
    _.each _.groupBy(_.filter(read, 'rid'), 'rid'), (messages, rid) =>
      unread[rid] = _.omit unread[rid], _.map(messages, 'id')
      delete unread[rid] if _.isEmpty unread[rid]
    # send if online otherwise store
    _.each _.groupBy(_.filter(send, 'rid'), 'rid'), (messages, rid) =>
      unsent[rid] = _.assign {}, unsent[rid], _.keyBy messages, 'id'
      if ws = clients[rid]
        ws.send JSON.stringify({ messages: _.values send }), =>
          unread[rid] = _.assign {}, unread[rid], unsent[rid]
          delete unsent[rid]
