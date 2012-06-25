$:.unshift(File.expand_path('../../lib', __FILE__))
$:.unshift(File.expand_path('../', __FILE__))

require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'adapter/spec/an_adapter'
require 'adapter/spec/types'
require 'adapter-mongo'

require 'support/shared_mongo_adapter'

RSpec.configure do |c|

end
