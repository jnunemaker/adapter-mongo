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
end