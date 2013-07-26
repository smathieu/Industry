test     = require('../lib/test.coffee')
industry = require('../lib/industry.coffee').industry

describe "Industry Model: ", ->

  it "Create new empty model", ->
    modelFactory = industry.defineModel()

    expect(modelFactory._data).toEqual({})
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).toEqual({})
    expect(modelFactory._klass).toEqual(false)
    expect(Object.keys(modelFactory._traits).length).toEqual(0)

    result = modelFactory.create()
    expect(result).toEqual({})


  it "Create model with object for default", ->
    modelFactory = industry.defineModel (f) ->
      f.data
        input: 'value'
        input1: 'value1'

    expect(modelFactory._data).toEqual(input: 'value', input1: 'value1')
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).toEqual({})
    expect(modelFactory._klass).toEqual(false)
    expect(Object.keys(modelFactory._traits).length).toEqual(0)

    result = modelFactory.create()
    expect(result).toEqual(input: 'value', input1: 'value1')


  it "Create model with anonymous function for default", ->
    time = null

    modelFactory = industry.defineModel (f) ->
      f.data ->
        time = new Date().getTime()

        time: time

    expect(modelFactory._data).toEqual({})
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).not.toEqual({})
    expect(modelFactory._base().time).toEqual(time)
    expect(modelFactory._klass).toEqual(false)
    expect(Object.keys(modelFactory._traits).length).toEqual(0)

    result = modelFactory.create()
    expect(result.time).toEqual(time)


  it "Create model with traits", ->
    time = null

    modelFactory = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time = new Date().getTime()

        time: time

    expect(modelFactory._data).toEqual(input: 'value')
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).toEqual({})
    expect(modelFactory._klass).toEqual(false)
    expect(Object.keys(modelFactory._traits).length).toEqual(1)

    result = modelFactory.create('currentTime')
    expect(result.time).toEqual(time)


  describe "Create model with traits, with sub options", ->
    factory = null
    time = null

    beforeEach ->
      factory = industry.defineModel (f) ->
        f.data
          input: 'value'

        f.trait 'currentTime', ->
          time = new Date().getTime()

          time: time

        f.trait 'option', (options) ->
          ret = {}

          if options.hasOption('apple')
            ret['options_apple'] = true
          if options.hasOption('pizza')
            ret['options_pizza'] = true
          if options.hasOption('orange')
            ret['options_orange'] = true

          ret

        f.trait 'option_one', (options, passed_arg, other_arg) ->
          ret = {}

          if options.hasOption('pistachio')
            ret['pistachio_options'] = true
          if passed_arg['variable'] is 'value'
            ret['hash_value'] = true
          if other_arg == 'hai'
            ret['string_value'] = true

          ret

      expect(factory._data).toEqual(input: 'value')
      expect(typeof factory._base).toEqual('function')
      expect(factory._base()).toEqual({})
      expect(factory._klass).toEqual(false)
      expect(Object.keys(factory._traits).length).toEqual(3)

    afterEach ->
      factory = null
      time = null

    it "and specific options", ->
      result = factory.create('option:apple:pizza')

      expect(result.options_apple).toBeTruthy()
      expect(result.options_pizza).toBeTruthy()
      expect(result.options_orange).toEqual(undefined)

    it "and all options", ->
      result = factory.create('option:all!')

      expect(result.options_apple).toBeTruthy()
      expect(result.options_pizza).toBeTruthy()
      expect(result.options_orange).toBeTruthy()

    it "using hash options", ->
      result = factory.option_one({variable: 'value'}, 'hai').create('option_one:pistachio')

      expect(result.pistachio_options).toBeTruthy()
      expect(result.hash_value).toBeTruthy()
      expect(result.string_value).toBeTruthy()

  it "Create model from a parent", ->
    time = null

    parent = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time = new Date().getTime()

        time: time

    modelFactory = industry.defineModel parent: parent, (f) ->
      f.data ->
        new_input: 'child'

    expect(modelFactory._data).toEqual(input: 'value')
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).toEqual(new_input: 'child')
    expect(modelFactory._klass).toEqual(false)
    expect(Object.keys(modelFactory._traits).length).toEqual(1)

    result = modelFactory.create('currentTime')
    expect(Object.keys(result)).toEqual(['input', 'new_input', 'time'])
    expect(result.time).toEqual(time)


  it "Create model with a class", ->
    time = null

    parent = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time = new Date().getTime()

        time: time

    modelFactory = industry.defineModel parent: parent, (f) ->
      f.data ->
        new_input: 'child'

      f.klass test.MyClass

    expect(modelFactory._data).toEqual(input: 'value')
    expect(typeof modelFactory._base).toEqual('function')
    expect(modelFactory._base()).toEqual(new_input: 'child')
    expect(modelFactory._klass).toEqual(test.MyClass)
    expect(Object.keys(modelFactory._traits).length).toEqual(1)

    modelFactory.data(fruit: 'orange')

    result = modelFactory.create('currentTime')
    expect(Object.keys(result.data)).toEqual(['input', 'fruit', 'new_input', 'time'])
