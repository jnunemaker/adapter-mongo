require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'adapter/mongo'

key     = BSON::OrderedHash['s' => 1, 'n' => 1]
client  = Mongo::Connection.new.db('adapter')['testing']
adapter = Adapter[:mongo].new(client)
adapter.clear

adapter.write(key, :v => 1)

doc = adapter.read(key)

puts doc.inspect
