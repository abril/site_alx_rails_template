require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = File.join(Rails.root, 'features/fixtures') if Rails.root.present?
  c.hook_into :webmock
  c.ignore_localhost = true
  c.default_cassette_options = { :record => :once }
end

Around do |scenario, block|
  file = scenario.respond_to?(:feature) ? scenario.feature.file : scenario.scenario_outline.feature.file
  vcr = File.basename(file, '.feature').gsub /^\d+-/, ''
  VCR.use_cassette vcr, :record => :new_episodes do
    block.call
  end
end
