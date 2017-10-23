noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Convolver extends noflo.Component
  description: 'Applies impulse response data to a given audio signal'
  icon: 'share-alt'
  constructor: ->
    ports =
      audionodes:
        datatype: 'object'
        description: 'audio nodes (oscillators, buffer sources, ...)'
        addressable: true
        required: true
      impulse:
        datatyle: 'string'
        description: 'impulse response filepath'
        required: true

    ArrayableHelper @, 'convolver', ports

exports.getComponent = -> new Convolver
