require 'adapter/mongo'

Adapter.define(:mongo_atomic, Adapter::Mongo) do
  # Public
  def write(key, attributes, options = nil)
    criteria = {:_id => key}
    updates = {'$set' => attributes}
    options = operation_options(options).merge(:upsert => true)
    client.update(criteria, updates, options)
  end
end
