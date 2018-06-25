Ajv = require 'ajv'
schema = require './schema'

module.exports = exports = new Ajv().compile schema
