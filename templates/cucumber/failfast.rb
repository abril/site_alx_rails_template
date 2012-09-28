if ENV['FAILFAST']
  After do |scenario|
    Cucumber.wants_to_quit = scenario.failed?
  end
end
