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
end

RSpec.configure do |c|

end
