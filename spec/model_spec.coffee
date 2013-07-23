test     = require('../lib/test.coffee')
industry = require('../lib/industry.coffee').industry

describe "Industry Model: ", ->

  it "Create new empty model", ->
    model = industry.model.define()

    expect(model._data).toEqual({})
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(0)

    result = model.create()
    expect(result).toEqual({})


  it "Create model with object for default", ->
    model = industry.model.define (f) ->
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
    model = industry.model.define (f) ->
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
    model = industry.model.define (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(1)

    result = model.create(null, 'currentTime')
    expect(result.time).toBeCloseTo(new Date().getTime(), 0)


  it "Create model from a parent", ->
    parent = industry.model.define (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    model = industry.model.define parent: parent, (f) ->
      f.data ->
        new_input: 'child'

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual(new_input: 'child')
    expect(model._klass).toEqual(false)
    expect(Object.keys(model._traits).length).toEqual(1)

    result = model.create(null, 'currentTime')
    expect(Object.keys(result)).toEqual(['input', 'new_input', 'time'])
    expect(result.time).toBeCloseTo(new Date().getTime(), 0)


  it "Create model with a class", ->
    parent = industry.model.define (f) ->
      f.data
        input: 'value'

      f.trait 'currentTime', ->
        time: new Date().getTime()

    model = industry.model.define parent: parent, (f) ->
      f.data ->
        new_input: 'child'

      f.klass test.MyClass

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual(new_input: 'child')
    expect(model._klass).toEqual(test.MyClass)
    expect(Object.keys(model._traits).length).toEqual(1)

    result = model.create(fruit: 'orange', 'currentTime')
    expect(Object.keys(result.data)).toEqual(['input', 'new_input', 'fruit', 'time'])
