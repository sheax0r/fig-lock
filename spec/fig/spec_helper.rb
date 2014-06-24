$:.unshift(File.join(__dir__), '..', '..', 'lib')
$:.unshift(File.join(__dir__), '..', '..', 'spec')

require 'rspec'

RSpec.configure do |config|
  require 'simplecov'
  SimpleCov.add_filter 'vendor'
  SimpleCov.add_filter 'spec'
  SimpleCov.start
end

require 'fig/lock'
