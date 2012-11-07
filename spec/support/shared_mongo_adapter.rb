shared_examples_for "a mongo adapter" do
  it_should_behave_like 'an adapter'

  it "allows using object id's as keys in correct type" do
    id = BSON::ObjectId.new
    attributes = {'one' => 'two'}
    adapter.write(id, attributes)
    client.find_one('_id' => id).should_not be_nil
    adapter.read(id).should == attributes
  end

  it "allows using ordered hashes as keys" do
    key = BSON::OrderedHash['d', 1, 'n', 1]
    attributes = {'one' => 'two'}
    adapter.write(key, attributes)
    client.find_one('_id' => key).should_not be_nil
    adapter.read(key).should == attributes
  end

  it "allows using hashes as keys" do
    key = {:d => 1}
    attributes = {'one' => 'two'}
    adapter.write(key, attributes)
    client.find_one('_id' => key).should_not be_nil
    adapter.read(key).should == attributes
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
