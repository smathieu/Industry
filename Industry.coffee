class IndustryModel
  traits: {}
  _data: {}
  _base: -> {}
  _klass: false

  trait: (name, afunc) ->
    @traits[name] = afunc

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
      if @traits[trait]
        data = $.extend({}, data, @traits[trait].apply(@, []))

    for key, val of data
      if typeof val is 'function'
        data[key] = val()

    if @_klass then data = new @_klass(data)

    return data


class IndustryCollection extends IndustryModel

  create: (data, count, model, traits...) ->

    if data == null
      data = {}

    _klass = @_klass
    @_klass = false

    data = super(data, traits...)

    @_klass = _klass

    if ! count then count = 5

    collection = []

    for i in [1..count]
      collection.push(model.create(data, traits...))

    if @_klass then collection = new @_klass(collection)

    return collection


class ModelFactory
  klass: IndustryModel
  define: (options, callback) ->

    instance = new @klass

    if ! callback and typeof options is 'function'
      callback = options

    else if typeof options is 'object'

      if options.parent
        instance.base(options.parent._base)
        instance.data(options.parent._data)
        instance.klass(options.parent._klass)

        for name, trait of options.parent.traits
          instance.trait(name, trait)

      if options.base
        instance.data(options.base)

      if options.traits
        for name, trait of options.traits
          instance.trait(name, options.traits[key])

      if options.klass
        instance.klass(options.klass)

    if typeof callback is 'function'
      callback(instance)

    return instance


class CollectionFactory extends ModelFactory
  klass: IndustryCollection

window.IndustryModel      = new IndustryModel
window.IndustryCollection = new IndustryCollection
window.ModelFactory       = new ModelFactory
window.CollectionFactory  = new CollectionFactory

