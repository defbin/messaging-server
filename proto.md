# WebSocket protocol for messaging

## Purpose
Because WebSocket is just transport protocol this document describes application protocol between server and client applications for messaging.

## Communication model
Client opens connection to server through ws:// protocol.
When connection established server sends unsent messages to the user. User should send back acknowledge reply that he/she read these messages. Each messages should be marked as read individually.
User can send one or many messages to many recipients at a time. If recipients are online, the server will send new messages immediately otherwise these messages will be sent when they become online.

### Security
Currently server does not have authorization. Anyone could connect to the server and identify himself by `client_id`. If several clients connected to server with the same `client_id`, latest takes precedence. So that, any messages could be read by anyone until they mark as read.

Messages are deleted when they mark as read. All messages are stored in memory. So that unsent and unread messages will be unavailable after server restart.

## Connection endpoint
Client should connect to `ws://{HOST}/messaging` and identify himself by `client_id` query parameters. `client_id` identify the user as sender or receipt in messages.

Connection to other endpoints are ignored. `401` will be returned if a user does not provide `client_id` or it is incorrect (e.g. 0, ‘’)

### Examples
`ws://localhost:8080/messaing?client_id=1452`

## Message payload
There are 2 types of data transfers: user commands, server notifications. On the top of each data payload there are sections. Section could be considered as command.
Unknown sections are ignored.

Messages must contain required fields. Other fields are just forwarded to the app.

### Required fields for sending message
```
id :: string or number   # message id
sid :: string or number  # sender id
rid :: string or number  # receiver id
```

### User Command payload
#### Sections
##### `send` - Send messages to recipients
Array of messages.

##### `read` - Mark as Read
Array of messages.

#### Example
```
{
	"send": [
		{ "id": 11, "rid": 31, "sid": 21, "text": "hello" },
		{ "id": 12, "rid": 32, "sid": 21, "url": "https://web.com/pic.png" }
	],
	"read": [
		{ "id": 1 },
		{ "id": 2 },
		{ "id": 3 }
	]
}
```
 
### Server Notifiction payload
#### Sections
##### `messages` - Sent messages to user
Array of messages.

#### Example
```
{
	"messages": [
		{ "id": 15, "rid": 31, "sid": 21, "text": "hello" },
		{ "id": 14, "rid": 31, "sid": 22, "url": "https://web.com/pic.png" }
	]
}
```

## Further improvements
- authorization (validation via service)
- guest
- channels
- broadcasting
- persistence storage
- device id support
