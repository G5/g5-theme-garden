source 'https://rubygems.org'
ruby '2.1.1'

gem "rails", "4.0.3"
gem "jquery-rails"

gem "quiet_assets", "~> 1.0.1"
gem "bootstrap-sass", "~> 2.1.0.1"
gem "microformats2", "~> 2.0.0"

group :assets do
  gem "sass-rails", "~> 4.0.0"
  gem "coffee-rails", "~> 4.0.0"
  gem "uglifier", ">= 1.0.3"
end

group :development, :test do
  gem "dotenv-rails"
  gem "rspec-rails"
  gem "pry"
  # ruby request specs
  gem "capybara"
  # ruby spec coverage
  gem "simplecov", require: false
  gem "codeclimate-test-reporter", require: false
  gem "foreman"
  gem "aws-sdk"
  gem "httparty"
end

group :production do
  gem "rails_12factor"
  gem "unicorn"
  gem "newrelic_rpm"
  gem "honeybadger"
  gem "lograge"
end
