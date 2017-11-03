noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class MakeTime extends noflo.Component
  description: 'Creates one or more time events'
  icon: 'clock-o'
  constructor: ->
    super()
    ports =
      time:
        datatype: 'number'
        description: 'when in future (ms)'
      offset:
        datatype: 'number'
        description: 'distance from start (ms)'
      duration:
        datatype: 'number'
        description: 'how long (ms)'

    ArrayableHelper @, 'time', ports

exports.getComponent = -> new MakeTime
