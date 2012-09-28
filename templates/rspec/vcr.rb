require 'vcr'

RSpec.configure do |config|
  config.extend VCR::RSpec::Macros
end

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/cassettes'
  config.default_cassette_options = { :record => :new_episodes }
end
