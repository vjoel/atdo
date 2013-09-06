atdo
====

At time, do code. That is all.

Oh, ok, if you insist, here's a little example:

```ruby
require 'atdo'

scheduler = AtDo.new
scheduler.at Time.now + 2 do
  puts "hello"
end
scheduler.at Time.now + 2 do
  puts "world"
end
sleep 3
```

And with rbtree storage instead of array:

```ruby
require 'atdo'
require 'rbtree'

scheduler = AtDo.new storage: MultiRBTree
scheduler.at Time.now + 2 do
  puts "hello"
end
scheduler.at Time.now + 2 do
  puts "world"
end
sleep 3
```

Both of these output

    hello
    world

See the unit tests for more examples.

The rbtree option is better for larger lists of tasks, especially with random inserts.
