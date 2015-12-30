require 'helper'

describe "Mongo atomic adapter" do
  before do
    @client = Mongo::MongoClient.new.db('test')['test']
    @adapter = Adapter[adapter_name].new(@client)
    @adapter.clear
  end

  let(:adapter_name) { :mongo_atomic }

  let(:adapter) { @adapter }
  let(:client)  { @client }

  it_should_behave_like 'a mongo adapter'

  it "allows updating only part of a document" do
    oid = BSON::ObjectId.new
    adapter.write(oid, {'a' => 'c', 'b' => 'd'})
    adapter.write(oid, {'a' => 'z'})
    expect(adapter.read(oid)).to eq({
      'a' => 'z',
      'b' => 'd',
    })
  end
end
