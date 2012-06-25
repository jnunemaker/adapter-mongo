require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

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
