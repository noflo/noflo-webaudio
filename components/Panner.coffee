noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Panner extends noflo.Component
  description: 'Changes the location of a given audio source'
  icon: 'compass'
  constructor: ->
    super()
    ports =
      audionodes:
        datatype: 'object'
        description: 'audio nodes (oscillators, buffer sources, ...)'
        addressable: true
        required: true
      position:
        datatyle: 'object'
        description: 'a 2D or 3D point'
        required: true

    ArrayableHelper @, 'panner', ports

exports.getComponent = -> new Panner
