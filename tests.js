model = ModelFactory.define(function(f) {
  f.data(function() {
    return {
      apple: 'pear',
      pizza: function() {
        return 'pepperoni';
      }
    };
  });

  f.trait('nickel', function() {
    return {other: 'data'};
  });
});

model = ModelFactory.define(function(f) {
  console.log(f);
});

