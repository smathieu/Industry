test     = require('../lib/test.coffee')
industry = require('../lib/industry.coffee').industry


describe "Industry Collection: ", ->


  it "Create new empty collection", ->

    modelFactory = industry.defineModel(data: {input: 'value'})

    expect(modelFactory._data[0]).toEqual(input: 'value')
    expect(modelFactory._klass).toEqual(false)
    expect(modelFactory._klass_callback).toEqual([])
    expect(Object.keys(modelFactory.traits).length).toEqual(0)

    collectionFactory = industry.defineCollection(model: modelFactory)

    expect(collectionFactory._data).toEqual([])
    expect(collectionFactory._klass).toEqual(false)
    expect(collectionFactory._klass_callback).toEqual([])
    expect(collectionFactory._model_callback).toEqual([])
    expect(collectionFactory._model).toEqual(modelFactory)

    expect(Object.keys(collectionFactory.traits).length).toEqual(0)

    result = collectionFactory.create(0, modelFactory)
    expect(result).toEqual([])


  it "Create collection with 1 model", ->

    modelFactory = industry.defineModel(data: {input: 'value'})

    expect(modelFactory._data[0]).toEqual(input: 'value')
    expect(modelFactory._klass).toEqual(false)
    expect(modelFactory._klass_callback).toEqual([])
    expect(Object.keys(modelFactory.traits()).length).toEqual(0)

    collectionFactory = industry.defineCollection(klass: test.MyCollection, model: modelFactory)

    expect(collectionFactory._data).toEqual([])
    expect(collectionFactory._klass).toEqual(test.MyCollection)
    expect(collectionFactory._klass_callback).toEqual([])
    expect(collectionFactory._model_callback).toEqual([])
    expect(collectionFactory._model).toEqual(modelFactory)

    result = collectionFactory.create(1)

    #console.log(result)

    expect(result.data.length).toEqual(1)


  it "Create collection with traits", ->

    traits = {
      new: ->
        other: 'one'
    }

    modelFactory = industry.defineModel(data: {input: 'value'}, klass: test.MyClass, traits: traits)

    expect(modelFactory._data[0]).toEqual(input: 'value')
    expect(modelFactory._klass).toEqual(test.MyClass)
    expect(modelFactory._klass_callback).toEqual([])
    expect(Object.keys(modelFactory._traits).length).toEqual(1)

    collectionFactory = industry.defineCollection klass: test.MyCollection, (f) ->
      f.trait 'pizza', ->
        pizza: 'pie'

    expect(collectionFactory._data).toEqual([])
    expect(collectionFactory._klass).toEqual(test.MyCollection)
    expect(collectionFactory._klass_callback).toEqual([])
    expect(collectionFactory._model_callback).toEqual([])
    expect(Object.keys(collectionFactory._traits).length).toEqual(1)

    result = collectionFactory.model(modelFactory).create(5, 'pizza', 'new').getResults()

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












