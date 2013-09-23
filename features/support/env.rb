require 'rbconfig'
require 'cucumber/formatter/unicode'
require 'capybara'
require 'capybara/dsl'
require "capybara/cucumber"
require 'selenium/webdriver'
# require 'stddtool'




Before do
  Capybara.default_driver = :selenium
  Capybara.default_wait_time = 5
   # = Selenium::WebDriver.for :firefox
end

After do |scenario|
  puts scenario.to_sexp
end


After do
  # Capybara.reset_sessions!
end

at_exit do
  puts 'at_exit'
	
end

World(Capybara)

