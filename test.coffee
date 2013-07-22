class MyClass
  constructor: (d) ->
    $.extend(@, d)

  apple: {}

window.MyClass = MyClass
