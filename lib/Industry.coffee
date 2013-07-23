class IndustryModel
  _traits: {}
  _data: {}
  _base: -> {}
  _klass: false

  constructor: (data) ->
    @_traits = {}
    @_data   = {}
    @_base   = -> {}
    @_klass  = false

  sequence: (name) ->
    ModelFactory.sequence(name)

  trait: (name, afunc) ->
    @_traits[name] = afunc

  traits: (traits) ->
    @_traits = $.extend(@_traits, traits)

  data: (options) ->
    if typeof options is 'function'
      @_base = options
    else
      @_data = $.extend({}, @_data, options)

  klass: (obj) ->
    @_klass = obj

  create: (data, traits...) ->

    if data == null
      data = {}

    data = $.extend({}, @_data, @_base(), data)

    for trait, i in traits
      if @_traits[trait]
        data = $.extend({}, data, @_traits[trait].call(@))

    for key, val of data
      if typeof val is 'function'
        data[key] = val.apply(@, [])

    if @_klass then data = new @_klass(data)

    return data


class IndustryCollection extends IndustryModel
  _model: false

  constructor: ->
    @_model = false
    super

  model: (m) ->
    @_model = m

  create: (data, count, model, traits...) ->

    if data == null
      data = {}

    _klass = @_klass
    @_klass = false

    data = super(data, traits...)

    @_klass = _klass

    if ! count then count = 5

    collection = []

    if ! model and @_model then model = @_model

    if typeof model != 'undefined' and model != null
      for i in [1..count]
        collection.push(model.create(data, traits...))

    if @_klass then collection = new @_klass(collection)

    return collection


class ModelFactory
  @_klass: IndustryModel
  @_sequences: {}

  @sequence: (name) ->
    if typeof @_sequences[name] is 'undefined'
      @_sequences[name] = 1
    else
      ++@_sequences[name]

  @define: (options, callback) ->

    instance = new @_klass

    if ! callback and typeof options is 'function'
      callback = options

    else if typeof options is 'object'

      if options.parent
        instance.data(options.parent._base)
        instance.data(options.parent._data)
        instance.klass(options.parent._klass)

        for name, trait of options.parent._traits
          instance.trait(name, trait)

      if options.data
        instance.data(options.data)

      if options.traits
        instance.traits(options.traits)

      if options.klass
        instance.klass(options.klass)

      if options.model
        instance.model(options.model)

    if typeof callback is 'function'
      callback(instance)

    return instance


class CollectionFactory extends ModelFactory
  @_klass: IndustryCollection


if typeof window != 'undefined'
  window.industry            = {}
  # window.IndustryModel      = IndustryModel
  # window.IndustryCollection = IndustryCollection
  window.industry.model       = ModelFactory
  window.industry.collection  = CollectionFactory
else if typeof module != 'undefined'
  _ = require('underscore')
  module.exports.industry            = {}
  #module.exports.IndustryModel      = IndustryModel
  #module.exports.IndustryCollection = IndustryCollection
  module.exports.industry.model       = ModelFactory
  module.exports.industry.collection  = CollectionFactory


if typeof $ is 'undefined' and typeof _ != 'undefined' then $ = _
else if typeof $ is 'undefined' and typeof _ is 'undefined'
  throw "Underscore.js or jQuery is required."
