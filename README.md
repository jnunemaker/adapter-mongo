# adapter-mongo

Mongo adapter for adapter gem.

```ruby
require 'adapter/mongo'

client  = Mongo::Connection.new.db('adapter')['testing']
adapter = Adapter[:mongo].new(client)
adapter.clear

adapter.write('foo', 'bar')
puts 'Should be bar: ' + adapter.read('foo').inspect

adapter.delete('foo')
puts 'Should be nil: ' + adapter.read('foo').inspect

adapter.write('foo', 'bar')
adapter.clear
puts 'Should be nil: ' + adapter.read('foo').inspect

puts 'Should be bar: ' + adapter.fetch('foo', 'bar')
```

## Flavors

There are two adapters included with this gem -- `:mongo` and `:mongo_atomic`. `:mongo` assumes that you are writing the full document each time. `:mongo_atomic` allows for partially updating documents. The difference is best show with a bit of code if you are unfamiliar.

```ruby
require 'adapter/mongo_atomic'

key            = BSON::ObjectId.new
full_doc       = {'a' => 'c', 'b' => 'd'}
partial_doc    = {'a' => 'z'}
client         = Mongo::Connection.new.db('adapter')['testing']
adapter        = Adapter[:mongo].new(client)
atomic_adapter = Adapter[:mongo_atomic].new(client)

adapter.clear
atomic_adapter.clear

adapter.write(key, full_doc)
adapter.write(key, partial_doc)

doc = adapter.read(key)
doc.delete('_id')

# full doc must always be written with :mongo adapter
puts 'Should be {"a"=>"z"}: ' + doc.inspect

atomic_adapter.write(key, full_doc)
atomic_adapter.write(key, partial_doc)

doc = atomic_adapter.read(key)
doc.delete('_id')

# partial updates can be written with atomic adapter as $set is used
puts 'Should be {"a"=>"z", "b"=>"d"}: ' + doc.inspect
```

See examples/ or specs/ for more usage.

## Contributing

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so we don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine, but bump version in a commit by itself so we can ignore when we pull)
* Send us a pull request. Bonus points for topic branches.
