class MyClass
  constructor: (d) ->
    @data = d

  data: {}

class MyCollection
  constructor: (d) ->
    @data = d

  getResults: ->
    @data

  data: [1,2,3,4,5]

if typeof window != 'undefined'
  window.MyClass = MyClass
  window.MyCollection = MyCollection
else if typeof module != 'undefined'
  $ = require('jquery')
  module.exports.MyClass = MyClass
  module.exports.MyCollection = MyCollection
