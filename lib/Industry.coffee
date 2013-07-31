class IndustryModel

  # Set all the instance variables to their default state
  constructor: (data) ->
    @_traits = {}
    @_traits_args = {}
    @_data   = []
    @_klass  = false
    @_klass_callback = []

  # Send sequences over to the meta factory
  sequence: (name) ->
    IndustryFactory.sequence(name)

  # Set a single trait
  trait: (name, afunc) ->
    @_traits[name] = afunc

    if typeof @[name] is 'undefined'
      @[name] = (args...) =>
        @_traits_args[name] = args
        @
    else
      throw "#{name} is a reserved name."
    @

  # Set multiple traits
  traits: (traits, args) ->
    if arguments.length < 1
      return @_traits
    else if traits == true
      return [@_traits, @_traits_args]

    @_traits = extend({}, @_traits, traits)

    if typeof args != 'undefined'
      @_traits_args = extend({}, @_traits_args, args)

    @

  # Set data
  data: (input) ->
    if arguments.length < 1
      return @_data

    if Object.prototype.toString.call(input) is '[object Array]'
      @_data = @_data.concat(input)
    else if typeof input is 'function' or typeof input is 'object'
      @_data.push(input)

    @

  # Set the klass to instantiate the data into
  klass: (obj, callback) ->

    if typeof obj == 'function' or obj == false
      @_klass = obj

    # If there was a call back set it
    @klass_callback(callback)

    @

  # Allow setting callbacks to be run on the instantiated klass
  # Note: This won't be run if you are being given JSON data back
  klass_callback: (callback) ->
    if callback is false or callback is 'reset'
      @_klass_callback = []

    if Object.prototype.toString.call(callback) != '[object Array]'
      callback = [callback]

    for item in callback
      if typeof item is 'function'
        @_klass_callback.push(item)

    @

  # Create the new model
  create: (traits...) ->

    data = {}

    # Process the "base" data
    for item in @_data
      if typeof item is 'function'
        item = item.call(@)
      data = extend({}, data, item)

    # Handle trait building
    new TraitSelection(@).each traits, (trait, d) =>
      data = extend({}, data, trait.apply(@, d))

    # Handle data manipulation
    for key, val of data
      if typeof val is 'function'
        data[key] = val.call(@)

    # Instantiate a klass if one was requested
    if @_klass != false
      data = new @_klass(data)

      # Process klass callbacks
      for callback in @_klass_callback
        if typeof callback is 'function'
          data = callback.call(@, data)

    return data


class IndustryCollection extends IndustryModel

  # Set all the instance variables to their default state
  constructor: ->
    @_model_callback = []
    @_model = false
    super

  # Set a model factory to use
  # on collection creation
  model: (m) ->
    @_model = m
    @

  # Set klass callbacks on the models
  model_callback: (callback) ->
    if callback is false or callback is 'reset'
      @_model_callback = []

    if Object.prototype.toString.call(callback) != '[object Array]'
      callback = [callback]

    for item in callback
      if typeof item is 'function'
        @_model_callback.push(item)

    @

  # Create the collection
  create: ->

    count  = 5
    traits = []

    # Set the amount of models and traits
    for argument in arguments
      if typeof argument is 'number'
        count = argument
      else
        traits.push(argument)

    # Temporarily store data as
    # run additional processing
    # from the model class
    _klass = @_klass
    @_klass = false
    data = super()
    @_klass = _klass

    collection = []

    # Verify the existence of a model
    if typeof @_model is 'undefined' or ! @_model
      throw "No model for collection"
    else

      # Create the models for the collection
      if count > 0
        for i in [1..count]
          # Pass data to the models for instantiation
          @_model.klass_callback(@_model_callback)
          @_model.traits(@_traits, @_traits_args)
          @_model.data(data)

          # Create and append the model to the collections array
          collection.push(@_model.create(traits...))

    # If we have a collection klass instantiate it
    if @_klass != false
      collection = new @_klass(collection)

      # Run any klass callbacks on the collection
      for callback in @_klass_callback
        if typeof callback is 'function'
          collection = callback.call(@, collection)

    return collection


class IndustryFactory
  klass = IndustryModel
  sequences = {}

  define = (options, callback) ->
    instance = new klass

    if ! callback and typeof options is 'function'
      callback = options

    else if typeof options is 'object'

      # Inheritance
      if options.parent
        instance.data(options.parent._base)
        instance.data(options.parent._data)
        instance.traits(options.parent._traits)
        instance.klass(options.parent._klass)
        instance.klass_callback(options.parent._klass_callback)

        if typeof options.parent._model_callback != 'undefined'
          instance.model_callback(options.parent._model_callback)

      # Options
      if options.data
        instance.data(options.data)

      if options.traits
        instance.traits(options.traits)

      if options.klass
        args = [options.klass]
        if options.klass_callback
          args.push(options.klass_callback)
        instance.klass(args...)
      else if options.klass_callback
        instance.klass_callback(options.klass_callback)

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

    trait_names = []

    # Start parsing the traits
    for trait in traits
      options = trait.split(':')
      name = options.shift()
      trait_names.push(name)

      trait = @obj._traits[name]
      args  = @obj._traits_args[name]

      if typeof trait != 'undefined'
        # The first argument will be the options
        option_tool =
          getObj: -> obj
          hasTrait: (name) -> trait_names.indexOf(name) != -1
          hasOption: -> @hasOptions(arguments...)
          hasOptions: (input...) ->
            if options.length < 1 then return false
            if options.indexOf('all!') != -1 then return true

            result = true
            for option in input
              result = (result && options.indexOf(option) != -1)

            return result

        callback trait, [option_tool].concat(args)

extend = (args...) ->
  if typeof window != 'undefined' and typeof window.$ != 'undefined' then window.$.extend(args...)
  else if typeof window != 'undefined' and typeof window._ != 'undefined' then window._.extend(args...)
  else if typeof window is 'undefined' and typeof global.$ != 'undefined' then $.extend(args...)
  else if typeof window is 'undefined' and typeof global._ != 'undefined' then _.extend(args...)
  else throw "Underscore.js or jQuery is required."

upStart = ->
  if typeof window is 'undefined' then global._ = require('underscore')
  if typeof window is 'undefined' then module.exports.industry = IndustryFactory
  if typeof window != 'undefined' then window.industry = IndustryFactory

upStart()
