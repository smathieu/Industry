test     = require('../lib/test.coffee')
industry = require('../lib/industry.coffee').industry

describe "Industry Collection: ", ->

  it "Create new empty collection", ->

    model = industry.defineModel(data: {input: 'value'})

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model.traits()).length).toEqual(0)

    collection = industry.defineCollection()

    expect(collection._data).toEqual({})
    expect(typeof collection._base).toEqual('function')
    expect(collection._base()).toEqual({})
    expect(collection._klass).toEqual(false)
    expect(Object.keys(collection.traits).length).toEqual(0)

    result = collection.create(0, model)
    expect(result).toEqual([])


  it "Create collection with 1 model", ->

    model = industry.defineModel(data: {input: 'value'})

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(false)
    expect(Object.keys(model.traits()).length).toEqual(0)

    collection = industry.defineCollection(klass: test.MyCollection, model: model)

    expect(collection._data).toEqual({})
    expect(typeof collection._base).toEqual('function')
    expect(collection._base()).toEqual({})
    expect(collection._klass).toEqual(test.MyCollection)
    expect(Object.keys(collection.traits()).length).toEqual(0)

    result = collection.create(1)
    expect(result.data.length).toEqual(1)


  it "Create collection with traits", ->

    traits = {
      new: ->
        other: 'one'
    }

    model = industry.defineModel(data: {input: 'value'}, klass: test.MyClass, traits: traits)

    expect(model._data).toEqual(input: 'value')
    expect(typeof model._base).toEqual('function')
    expect(model._base()).toEqual({})
    expect(model._klass).toEqual(test.MyClass)
    expect(Object.keys(model._traits).length).toEqual(1)

    collection = industry.defineCollection klass: test.MyCollection, (f) ->
      f.trait 'pizza', ->
        pizza: 'pie'

    expect(collection._data).toEqual({})
    expect(typeof collection._base).toEqual('function')
    expect(collection._base()).toEqual({})
    expect(collection._klass).toEqual(test.MyCollection)
    expect(Object.keys(collection._traits).length).toEqual(1)

    result = collection.create(5, model, 'pizza', 'new').getResults()

    expect(result.length).toEqual(5)
    expect(Object.keys(result[0].data)).toEqual(['input', 'pizza', 'other'])

  it "Create a collection with sequences", ->

    modelFactory = industry.defineModel (f) ->

      f.data ->
        id: "test_#{f.sequence('id')}"
        name: "Milly"


    collectionFactory = industry.defineCollection model: modelFactory, (f) ->

      f.trait 'email', ->
        email: "example#{f.sequence('email')}@google.com"


    collection = collectionFactory.create(5, 'email')

    expect(collection.length).toEqual(5)

    for model, i in collection
      expect(model.id).toEqual("test_#{i+1}")
      expect(model.email).toEqual("example#{i+1}@google.com")
      expect(model.name).toEqual('Milly')












