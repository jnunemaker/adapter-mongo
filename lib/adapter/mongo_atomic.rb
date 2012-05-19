require 'adapter/mongo'

Adapter.define(:mongo_atomic, Adapter::Mongo) do
  def write(key, value)
    criteria = {:_id => key_for(key)}
    updates  = {'$set' => encode(value)}
    client.update(criteria, updates, :upsert => true, :safe => options[:safe])
  end
end
