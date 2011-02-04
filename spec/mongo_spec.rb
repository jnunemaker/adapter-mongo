require 'helper'
require 'adapter/mongo'

describe "Mongo adapter" do
  before do
    @client = Mongo::Connection.new.db('adapter')['testing']
    @adapter = Adapter[:mongo].new(@client)
    @adapter.clear
  end

  let(:adapter) { @adapter }
  let(:client)  { @client }

  it_should_behave_like 'a mongo adapter'

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
      @adapter = Adapter[:mongo].new(@client, :safe => true)
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