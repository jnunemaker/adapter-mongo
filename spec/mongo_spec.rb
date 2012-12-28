require 'helper'

describe "Mongo adapter" do
  before do
    @client = Mongo::MongoClient.new.db('test')['test']
    @adapter = Adapter[adapter_name].new(@client)
    @adapter.clear
  end

  let(:adapter_name) { :mongo }

  let(:adapter) { @adapter }
  let(:client)  { @client }

  it_should_behave_like 'a mongo adapter'
end
