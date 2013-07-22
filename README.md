# Industry

**Factories for JavaScript/Backbone.js, coming soon to a rainforest near you.** :D

# Usage

Basic Model usage with traits.

```coffeescript
model = ModelFactory.define (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


newModel = model.create(null, 'passed')


newModel.id
# => 'step_1'


newModel.created_at
# => DateStamp


newModel.result
# => 'passed'
```

Using shared traits

```coffeescript
sharedTraits = {
  passed: ->
    result: 'passed'
  failed: ->
    result: 'failed'
  set_active: ->
    status: 'active'
}


model = ModelFactory.define traits: sharedTraits, (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()


newModel = model.create(null, 'passed', 'set_active')

newModel.id
# => 'step_1'


newModel.created_at
# => DateStamp


newModel.result
# => 'passed'


newModel.status
# => 'active'
```

Using parent models

```coffeescript
firstModel = ModelFactory.define (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


secondModel = ModelFactory.define parent: firstModel, (f) ->

  f.trait 'set_active', ->
    status: active


newModel = model.create(null, 'passed')


newModel.id
# => 'step_1'


newModel.created_at
# => DateStamp


newModel.result
# => 'passed'


newModel.status
# => 'active'
```

Using a collection

```coffeescript
model = ModelFactory.define (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


collection = CollectionFactory.define(model: model)


results = collection.create(null, 5)


results.length
# => 5


results[0].id
# => 'step_1'


results[1].id
# => 'step_2'
```

# Running Tests

We use Node, NPM and Jasmine to test Industry.

1. `npm install`
2. `npm test`
