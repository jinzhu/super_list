# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"
require 'factory_girl'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require File.expand_path(File.join(File.dirname(__FILE__), "factories"))

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
