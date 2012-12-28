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
    context "set to true" do
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

    context "set to false" do
      before do
        client.ensure_index([['email', 1]], :unique => true)
        @adapter = Adapter[adapter_name].new(client, :safe => false)
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

      it "does not raise operation failure on write if operation fails" do
        adapter.write(BSON::ObjectId.new, {'email' => 'john@orderedlist.com'})
        lambda {
          adapter.write(BSON::ObjectId.new, {'email' => 'john@orderedlist.com'})
        }.should_not raise_error(Mongo::OperationFailure)
      end
    end
  end

  describe "with :write_concern" do
    before do
      client.ensure_index([['email', 1]], :unique => true)
      @adapter = Adapter[adapter_name].new(client, :write_concern => {:w => 1})
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

    it "allows overriding write concern for write" do
      id = BSON::ObjectId.new
      client.should_receive(:update).
        with(
          hash_including(:_id),
          kind_of(Hash),
          hash_including(:w => 0)
        )
      adapter.write(id, {:foo => 'bar'}, :w => 0)
    end

    it "uses write concern for delete" do
      id = BSON::ObjectId.new
      client.should_receive(:remove).with({:_id => id}, :w => 1)
      adapter.delete(id)
    end

    it "allows overriding write concern for delete" do
      id = BSON::ObjectId.new
      client.should_receive(:remove).with({:_id => id}, :w => 0)
      adapter.delete(id, :w => 0)
    end

    it "uses write concern for clear" do
      id = BSON::ObjectId.new
      client.should_receive(:remove).with({}, :w => 1)
      adapter.clear
    end

    it "allows overriding write concern for clear" do
      id = BSON::ObjectId.new
      client.should_receive(:remove).with({}, :w => 0)
      adapter.clear(:w => 0)
    end
  end
end
