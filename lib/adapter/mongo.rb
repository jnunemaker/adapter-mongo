require 'adapter'
require 'mongo'

module Adapter
  module Mongo
    def read(key)
      if doc = client.find_one('_id' => key_for(key))
        decode(doc)
      end
    end

    def read_multiple(*keys)
      ids = keys.map { |key| key_for(key) }
      docs = client.find('_id' => {'$in' => ids}).to_a

      docs_by_id = BSON::OrderedHash[docs.map { |doc|
        [doc.delete('_id'), doc]
      }]

      result = {}
      keys.each do |key|
        key = key_for(key)
        result[key] = docs_by_id[key]
      end
      result
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
