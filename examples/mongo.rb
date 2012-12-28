require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/mongo'

key     = BSON::ObjectId.new
client  = Mongo::MongoClient.new.db('adapter')['testing']
adapter = Adapter[:mongo].new(client)
adapter.clear

adapter.write(key, {'some' => 'thing'})
puts 'Should be {"some" => "thing"}: ' + adapter.read(key).inspect

adapter.delete(key)
puts 'Should be nil: ' + adapter.read(key).inspect

adapter.write(key, {'some' => 'thing'})
adapter.clear
puts 'Should be nil: ' + adapter.read(key).inspect

puts 'Should be {"some" => "thing"}: ' + adapter.fetch(key, {'some' => 'thing'}).inspect
