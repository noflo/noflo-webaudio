noflo = require 'noflo'
ArrayableHelper = require 'noflo-helper-arrayable'

class AudioFile extends noflo.Component
  description: 'Create an audio source loading a sound file'
  icon: 'file-audio-o'
  constructor: ->
    super()
    ports =
      file:
        datatype: 'string'
        description: 'URL of file to load'
        required: true
      play:
        datatype: 'bang'
        description: 'plays the file right now'
      start:
        datatype: 'object'
        description: 'schedules to playback {time, offset, duration}'
      stop:
        datatype: 'number'
        description: 'schedules to stop at an exact time'

    ArrayableHelper @, 'audiofile', ports

exports.getComponent = -> new AudioFile
