require 'adapter'
require 'mongo'

module Adapter
  module Mongo

    # Public
    def read(key, options = nil)
      if doc = client.find_one('_id' => key)
        clean(doc)
      end
    end

    # Public
    def read_multiple(keys, options = nil)
      ids = keys.map { |key| key }
      docs = client.find('_id' => {'$in' => ids}).to_a
      keys_and_values = docs.map { |doc| [doc.delete('_id'), doc] }

      docs_by_id = Hash[keys_and_values]

      result = {}
      keys.each do |key|
        key = key
        result[key] = docs_by_id[key]
      end
      result
    end

    # Public
    def write(key, attributes, options = nil)
      options = operation_options(options)
      client.save(attributes.merge('_id' => key), options)
    end

    # Public
    def delete(key, options = nil)
      options = operation_options(options)
      client.remove({:_id => key}, options)
    end

    # Public
    def clear(options = nil)
      options = operation_options(options)
      client.remove({}, options)
    end

    # Private
    def clean(doc)
      doc.delete('_id')
      doc
    end

    # Private
    def operation_options(options)
      write_concern.merge(options || {})
    end

    # Private
    def write_concern
      if options[:write_concern]
        options[:write_concern]
      else
        if options[:safe]
          {:w => 1}
        else
          {:w => 0}
        end
      end
    end
  end
end

Adapter.define(:mongo, Adapter::Mongo)
