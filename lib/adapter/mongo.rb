require 'adapter'
require 'mongo'

module Adapter
  module Mongo
    def read(key)
      if doc = client.find_one('_id' => key_for(key))
        decode(doc)
      end
    end

    def write(key, value)
      client.save({'_id' => key_for(key)}.merge(encode(value)), {:safe => options[:safe]})
    end

    def delete(key)
      read(key).tap { client.remove({'_id' => key_for(key)}, {:safe => options[:safe]}) }
    end

    def clear
      client.remove
    end

    def decode(value)
      value.delete('_id')
      value
    end
  end
end

Adapter.define(:mongo, Adapter::Mongo)
