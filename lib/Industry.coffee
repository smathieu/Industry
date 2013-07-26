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
    IndustryFactory.sequence(name)

  trait: (name, afunc) ->
    @_traits[name] = afunc

  traits: (traits) ->
    if arguments.length < 1
      return @_traits

    @_traits = $.extend({}, @_traits, traits)

  data: (options) ->
    if typeof options is 'function'
      @_base = options
    else
      @_data = $.extend({}, @_data, options)

  klass: (obj) ->
    @_klass = obj

  create: (traits...) ->

    data = $.extend({}, @_data, @_base())

    new TraitSelection(@).each traits, (trait, d) =>
      data = $.extend({}, data, trait.apply(@, d))

    for key, val of data
      if typeof val is 'function'
        data[key] = val.call(@)

    if @_klass then data = new @_klass(data)

    return data


class IndustryCollection extends IndustryModel
  _model: false

  constructor: ->
    @_model = false
    super

  model: (m) ->
    @_model = m

  create: ->

    count  = 5
    traits = []

    # Not parsing json data here
    # The hassle is tooo much!
    # Suggestions welcome
    for argument in arguments
      if typeof argument.constructor != 'undefined' and argument.constructor.name == 'IndustryModel'
        model = argument
      else if typeof argument is 'number'
        count = argument
      else
        traits.push(argument)

    _klass = @_klass
    @_klass = false

    data = super()

    @_klass = _klass

    collection = []

    if ! model and @_model then model = @_model

    if typeof model is 'undefined' or model is null
      throw "No model for collection"
    else
      if count > 0
        for i in [1..count]
          # Set the data and traits on the model
          model.traits(@_traits)
          model.data(data)

          collection.push(model.create(traits...))

    if @_klass then collection = new @_klass(collection)

    return collection


class IndustryFactory
  klass = IndustryModel
  sequences = {}

  define = (options, callback) ->
    instance = new klass

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

  @sequence: (name) ->
    if typeof sequences[name] is 'undefined'
      sequences[name] = 1
    else
      ++sequences[name]

  @defineCollection: ->
    klass = IndustryCollection
    define.apply(@, arguments)

  @defineModel: (options, callback) ->
    klass = IndustryModel
    define.apply(@, arguments)


class TraitSelection
  @obj: false

  constructor: (obj) ->
    @obj = obj

  each: (traits, callback) ->

    newtraits = {}
    for trait in traits
      # Make sure traits are in hash form (even if passed as a array)
      if typeof trait is 'string'
        newtraits[trait] = []
      if typeof trait is 'object'
        newtraits = $.extend({}, newtraits, trait)

    traits = newtraits

    # Start parsing the traits
    for trait, arguments of traits
      options = trait.split(':')
      name = options.shift()
      trait = @obj._traits[name]

      if typeof trait != 'undefined'
        # The first argument will be the options
        option_tool =
          hasOption: -> @hasOptions(arguments...)
          hasOptions: (input...) ->
            if options.length < 1 then return false
            if options.indexOf('all!') != -1 then return true

            result = true
            for option in input
              result = (result && options.indexOf(option) != -1)

            return result

        callback trait, [option_tool].concat(arguments)


if typeof window != 'undefined'
  window.industry = IndustryFactory
else if typeof module != 'undefined'
  _ = require('underscore')
  module.exports.industry = IndustryFactory


if typeof $ is 'undefined' and typeof _ != 'undefined' then $ = _
else if typeof $ is 'undefined' and typeof _ is 'undefined'
  throw "Underscore.js or jQuery is required."
