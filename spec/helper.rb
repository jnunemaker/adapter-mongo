$:.unshift(File.expand_path('../../lib', __FILE__))

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'adapter/spec/an_adapter'
require 'adapter/spec/types'
require 'adapter-mongo'

shared_examples_for "a mongo adapter" do
  it_should_behave_like 'an adapter'

  Adapter::Spec::Types.each do |type, (key, key2)|
    it "writes Object values to keys that are #{type}s like a Hash" do
      adapter[key] = {:foo => :bar}
      # mongo knows hashes and can serialize symbol values
      adapter[key].should == {'_id' => 'key', 'foo' => :bar}
    end
  end

  it "allows using object id's as keys in correct type" do
    id = BSON::ObjectId.new
    adapter.write(id, 'ham')
    client.find_one('_id' => id).should_not be_nil
    adapter.read(id).should == 'ham'
  end

  it "stores hashes right in document" do
    adapter.write('foo', 'steak' => 'bacon')
    client.find_one('_id' => 'foo').should == {'_id' => 'foo', 'steak' => 'bacon'}
  end

  describe "with safe option" do
    before do
      client.ensure_index([['email', 1]], :unique => true)
      @adapter = Adapter[adapter_name].new(client, :safe => true)
    end

    after do
      client.drop_index('email_1')
    end

    it "does not raise operation failure on write if operation succeeds" do
      adapter.write(BSON::ObjectId.new, {'email' => 'john@orderedlist.com'})
      lambda {
        adapter.write(BSON::ObjectId.new, {'email' => 'steve@orderedlist.com'})
      }.should_not raise_error(Mongo::OperationFailure)
    end

    it "raises operation failure on write if operation fails" do
      adapter.write(BSON::ObjectId.new, {'email' => 'john@orderedlist.com'})
      lambda {
        adapter.write(BSON::ObjectId.new, {'email' => 'john@orderedlist.com'})
      }.should raise_error(Mongo::OperationFailure)
    end
  end
end

RSpec.configure do |c|

end
