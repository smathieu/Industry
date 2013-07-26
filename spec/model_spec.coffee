test     = require('../lib/test.coffee')
industry = require('../lib/industry.coffee').industry

describe "Industry Model: ", ->

  it "Create new empty model", ->
    model = industry.defineModel()

    expect(model._data).toEqual({})
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(0)

    result = model.create()
    expect(result).toEqual({})


  it "Create model with object for default", ->
    model = industry.defineModel (f) ->
      f.data
        input: 'value'
        input1: 'value1'

    expect(model._data).toEqual(input: 'value', input1: 'value1')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(0)

    result = model.create()
    expect(result).toEqual(input: 'value', input1: 'value1')


  it "Create model with anonymous function for default", ->
    model = industry.defineModel (f) ->
      f.data ->
        time = new Date().getTime()
        {time: time}

    expect(model._data).toEqual({})
    expect(typeof model._base).toEqual('function')
    expect(model._base()).not.toEqual({})
    expect(model._base().time).toBeCloseTo(new Date().getTime(), 0)
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(0)

    result = model.create()
    expect(result.time).toBeCloseTo(new Date().getTime(), 0)


  it "Create model with traits", ->
    model = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(1)

    result = model.create('currentTime')
    expect(result.time).toBeCloseTo(new Date().getTime(), 0)


  describe "Create model with traits, with sub options", ->
    factory = null

    beforeEach ->
      factory = industry.defineModel (f) ->
        f.data
          input: 'value'

        f.trait 'currentTime', ->
          time: new Date().getTime()

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
      result = factory.create('option_one:pistachio': [{variable: 'value'}, 'hai'])

      expect(result.pistachio_options).toBeTruthy()
      expect(result.hash_value).toBeTruthy()
      expect(result.string_value).toBeTruthy()

  it "Create model from a parent", ->
    parent = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    model = industry.defineModel parent: parent, (f) ->
      f.data ->
        new_input: 'child'

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual(new_input: 'child')
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(1)

    result = model.create('currentTime')
    expect(Object.keys(result)).toEqual(['input', 'new_input', 'time'])
    expect(result.time).toBeCloseTo(new Date().getTime(), 0)


  it "Create model with a class", ->
    parent = industry.defineModel (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    model = industry.defineModel parent: parent, (f) ->
      f.data ->
        new_input: 'child'

      f.klass test.MyClass

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual(new_input: 'child')
    expect(model._klass).toEqual(test.MyClass)
    expect(Object.keys(model._traits).length).toEqual(1)

    model.data(fruit: 'orange')

    result = model.create('currentTime')
    expect(Object.keys(result.data)).toEqual(['input', 'fruit', 'new_input', 'time'])
