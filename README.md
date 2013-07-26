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


model = modelFactory.create('passed')


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


model = modelFactory.create('passed', 'set_active')


model.id
# => 'step_1'


model.created_at
# => DateStamp


model.result
# => 'passed'


model.status
# => 'active'
```

Using traits with options

```coffeescript
modelFactory = industry.defineModel (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'permissions', (options), ->
    return_value = {}

    if options.hasOption('admin')
      return_value['admin'] = true
    if options.hasOption('moderator')
      return_value['moderator'] = true
    if options.hasOption('member')
      return_value['member'] = true

    return return_value


model = modelFactory.create('passed', 'set_active', 'permissions')

model.permissions
# => {}


model = modelFactory.create('passed', 'set_active', 'permissions:member')

model.permissions
# => {member: true}


model = modelFactory.create('passed', 'set_active', 'permissions:member:moderator')

model.permissions
# => {member: true, moderator: true}


model = modelFactory.create('passed', 'set_active', 'permissions:all!')

model.permissions
# => {member: true, moderator: true, admin: true}
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


model = secondModelFactory.create('passed')


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


collection = collectionFactory.create(5)


collection.length
# => 5


collection[0].id
# => 'step_1'


collection[1].id
# => 'step_2'
```

Using a Backbone.js model

```coffeescript
modelFactory = industry.defineModel klass: MyBackBoneModel, (f) ->

  f.data ->
    id: -> "step_#{f.sequence('id')}"
    created_at: -> new Date().toString()

  f.trait 'passed' , ->
    result: 'passed'

  f.trait 'failed' , ->
    result: 'failed'


model = modelFactory.create('passed')


model
=> Instance of MyBackboneModel
```

Using a Backbone.js collection

```coffeescript
modelFactory = industry.defineModel(klass: MyBackBoneCollection)


model
=> Instance of MyBackboneModel
```

_Note: the above example would throw an exception because there is no model being passed in!_

# Running Tests

We use Node, NPM and Jasmine to test Industry.

1. `npm install`
2. `npm test`
