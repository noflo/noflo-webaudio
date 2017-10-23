noflo = require 'noflo'

class PlayCommands
  constructor: (scope) ->
    @audionodes = scope.audionodes
    @table_audionodes = scope.table_audionodes
    @buffer_data = scope.buffer_data
    @context = scope.context

  parse: (audionodes) =>
    @walk audionodes, 0

  # Recursively walk through the AudioNodes' graph and connect them
  walk: (audionodes, level) =>
    for audionode in audionodes
      created = @create audionode
      # Connect top-level AudioNodes to destination
      if level is 0
        created.connect @context.destination
      if audionode.audionodes?
        # Has children?
        children = audionode.audionodes
        if children instanceof Array
          @walk(children, level+1).connect created
        else
          @walk([children], level+1).connect created
      else
        # Is child?
        return created

  create: (audionode) =>
    return @parseCommand audionode

  # noflo-canvas legacy
  parseCommand: (commands) =>
    return unless @context
    @parseThing commands

  # Recursively parse things and arrays of things
  parseThing: (thing, before, after) =>
    if thing? and thing.type? and @[thing.type]?
      if before?
        before()
      return @[thing.type](thing)
      if after?
        after()
    else if thing instanceof Array
      for item in thing
        continue unless item?
        @parseThing item, before, after

  # Instructions (AudioNodes)
  gain: (params) =>
    # For now update/create is almost the same, we should improve this ASAP
    # so we can get off this selection and to do specific things for each case
    if params.id of @table_audionodes
      audioNode = @table_audionodes[params.id]
    else
      audioNode = @context.createGain()
      @table_audionodes[params.id] = audioNode
    audioNode.gain.value = params.gain
    return audioNode

  oscillator: (params) =>
    if params.id of @table_audionodes
      audioNode = @table_audionodes[params.id]
    else
      audioNode = @context.createOscillator()
      # FIXME: How to deal with start?
      audioNode.start params.start
      @table_audionodes[params.id] = audioNode
    audioNode.type = params.waveform
    audioNode.frequency.value = params.frequency
    #audioNode.start params.start
    return audioNode

  panner: (params) =>
    if params.id of @table_audionodes
      audioNode = @table_audionodes[params.id]
    else
      audioNode = @context.createPanner()
      @table_audionodes[params.id] = audioNode
    # FIXME: Just 2D for now to interoperate with noflo-canvas
    audioNode.setPosition(params.position.x, params.position.y, 0)
    return audioNode

  audiofile: (params) =>
    if params.id of @table_audionodes
      # update
      # A bit different, we always create a new buffer source
      audioNode = @context.createBufferSource()
      @table_audionodes[params.id] = audioNode
      # Update the buffer data
      if @buffer_data[params.id]?
        @updateBuffer(audioNode, params.id)
        # Plays only on update
        {time, offset, duration} = params.start
        audioNode.start time, offset, duration
    else
      # create
      audioNode = @context.createBufferSource()
      @table_audionodes[params.id] = audioNode
      # XHR downloads and loads only at node creation
      request = new XMLHttpRequest()
      request.open("GET", params.file, true)
      request.responseType = "arraybuffer"
      request.onload = () =>
        @context.decodeAudioData request.response, (buffer) =>
          @buffer_data[params.id] = buffer
          # FIXME: Should we blink the component, how to do that from here?
          @updateBuffer(audioNode, params.id)
      request.send()

    return audioNode

  updateBuffer: (audionode, id) =>
    audionode.buffer = @buffer_data[id]

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Plays given chains and patterns'
  c.icon = 'play'
  c.inPorts.add 'audionodes',
    datatype: 'object'
    addressable: true

  c.scopes = {}
  c.tearDown = (callback) ->
    scopes = Object.keys c.scopes
    unless scopes.length
      do callback
      return
    scope = scopes[0]
    unless c.scopes[scope]?.context
      # Already torn down
      delete c.scopes[scope]
      c.tearDown callback
      return
    c.scopes[scope].context.close()
      .then ->
        delete c.scopes[scope]
        c.tearDown callback
      , (err) ->
        callback err
    return

  ensureScope = (scope) ->
    unless c.scopes[scope]
      # Create context and audionodes if scope doesn't exist
      context = new AudioContext()
      c.scopes[scope] =
        audionodes: []
        table_audionodes: {}
        buffer_data: {}
        context: context

    return c.scopes[scope]

  c.process (input, output) ->
    # Ensure that we have a scope storing context and audio nodes
    scope = ensureScope input.scope

    # Check if we've received audio nodes
    indexesWithData = input.attached('audionodes').filter (idx) ->
      input.hasData ['audionodes', idx]
    return unless indexesWithData.length

    # Play audio nodes
    play = new PlayCommands scope

    indexesWithData.forEach (idx) ->
      # Read audio nodes into scope
      scope.audionodes[idx] = input.getData ['audionodes', idx]
      # Parse each audio node
      if scope.audionodes[idx] instanceof Array
        play.parse scope.audionodes[idx]
      else
        play.parse [scope.audionodes[idx]]

    output.done()
    return
