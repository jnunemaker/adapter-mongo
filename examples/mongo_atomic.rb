require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/mongo_atomic'

client  = Mongo::Connection.new.db('adapter')['testing']
adapter = Adapter[:mongo_atomic].new(client)
adapter.clear

oid = BSON::ObjectId.new

adapter.write(oid, {'a' => 'c', 'b' => 'd'})
adapter.write(oid, {'a' => 'z'})

doc = adapter.read(oid)

puts 'Should be "z": ' + doc['a']
puts 'Should be "d": ' + doc['b']
