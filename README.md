# Industry

**Factories for JavaScript/Backbone.js, coming soon to a rainforest near you.** :D

# Dependencies

Test Dependencies

- Node
- NPM
- CoffeeScript
- Jasmine
- Underscore.js

Production Dependencies

- CoffeeScript (unless pre-compiled)
- Underscore.js or jQuery

# Usage

Basic Model usage with traits.

```coffeescript
modelFactory = industry.defineModel (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


model = modelFactory.create(null, 'passed')


model.id
# => 'step_1'


model.created_at
# => DateStamp


model.result
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


modelFactory = industry.defineModel traits: sharedTraits, (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()


model = modelFactory.create(null, 'passed', 'set_active')

model.id
# => 'step_1'


model.created_at
# => DateStamp


model.result
# => 'passed'


model.status
# => 'active'
```

Using parent models

```coffeescript
firstModelFactory = industry.defineModel (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


secondModelFactory = industry.defineModel parent: firstModelFactory, (f) ->

  f.trait 'set_active', ->
    status: active


model = secondModelFactory.create(null, 'passed')


model.id
# => 'step_1'


model.created_at
# => DateStamp


model.result
# => 'passed'


model.status
# => 'active'
```

Using a collection

```coffeescript
modelFactory = industry.defineModel (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


collectionFactory = industry.defineCollection(model: modelFactory)


collection = collectionFactory.create(null, 5)


collection.length
# => 5


collection[0].id
# => 'step_1'


collection[1].id
# => 'step_2'
```

# Running Tests

We use Node, NPM and Jasmine to test Industry.

1. `npm install`
2. `npm test`
