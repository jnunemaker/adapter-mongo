require 'adapter'
require 'mongo'

module Adapter
  module Mongo
    NonHashValueKeyName = '_value'

    def read(key)
      if doc = client.find_one('_id' => key_for(key))
        decode(doc)
      end
    end

    def write(key, value)
      client.save({'_id' => key_for(key)}.merge(encode(value)))
    end

    def delete(key)
      read(key).tap { client.remove('_id' => key_for(key)) }
    end

    def clear
      client.remove
    end

    def key_for(key)
      key.is_a?(BSON::ObjectId) ? key : super
    end

    def encode(value)
      value.is_a?(Hash) ? value : {NonHashValueKeyName => value}
    end

    def decode(value)
      return if value.nil?
      value.key?(NonHashValueKeyName) ? value[NonHashValueKeyName] : value
    end
  end
end

Adapter.define(:mongo, Adapter::Mongo)