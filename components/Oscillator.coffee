noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class Oscillator extends noflo.Component
  description: 'Create an audio source with a periodic waveform ' +
               '(sine, square, sawtooth, triangle, custom)'
  icon: 'volume-up'
  constructor: ->
    super()
    ports =
      waveform:
        datatype: 'string'
        description: 'sine, square, sawtooth, triangle, custom'
        required: true
      frequency:
        datatype: 'number'
        description: 'frequency of signal'
        required: true
      start:
        datatype: 'number'
        description: 'schedules to playback at an exact time'
      stop:
        datatype: 'number'
        description: 'schedules to stop at an exact time'

    ArrayableHelper @, 'oscillator', ports

exports.getComponent = -> new Oscillator
