noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Gain extends noflo.Component
  description: 'Multiplies the input audio signal by the given gain value, ' +
               'changing its amplitude.'
  icon: 'filter'
  constructor: ->
    super()
    ports =
      audionodes:
        datatype: 'object'
        description: 'audio nodes (oscillators, buffer sources, ...)'
        addressable: true
        required: true
      gain:
        datatyle: 'number'
        description: 'amount of gain to apply (0...1)'
        required: true

    ArrayableHelper @, 'gain', ports

exports.getComponent = -> new Gain
