ColorScanner = require '../color-scanner'
ColorContext = require '../color-context'
ColorExpression = require '../color-expression'
ExpressionsRegistry = require '../expressions-registry'
ColorsChunkSize = 100

class BufferColorsScanner
  constructor: (config) ->
    {@buffer, variables, colorVariables, bufferPath, registry} = config
    registry = ExpressionsRegistry.deserialize(registry, ColorExpression)
    @context = new ColorContext({variables, colorVariables, referencePath: bufferPath, registry})
    @scanner = new ColorScanner({@context})
    @results = []

  scan: ->
    lastIndex = 0
    while result = @scanner.search(@buffer, lastIndex)
      @results.push(result)

      @flushColors() if @results.length >= ColorsChunkSize
      {lastIndex} = result

    @flushColors()

  flushColors: ->
    emit('scan-buffer:colors-found', @results)
    @results = []

module.exports = (config) ->
  new BufferColorsScanner(config).scan()
