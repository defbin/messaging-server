ID =
  anyOf: [
    { type: 'string' }
    { type: 'number' }
  ]

module.exports = exports =
  properties:
    send:
      type: 'array'
      items:
        type: 'object'
        required: ['id', 'rid']
        properties:
          id: ID
          rid: ID
          sid: ID
    read:
      type: 'array'
      items:
        type: 'object'
        required: ['id']
        properties:
          id: ID
