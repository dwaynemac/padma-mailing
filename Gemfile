source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'activity_stream_client', '~> 0.0.10'
gem 'ffi', '~> 1.0.11'

gem 'accounts_client', '~> 0.0.12'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '1.0.0.alpha13'

# authorization
gem 'cancan'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem "less-rails"
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
  gem 'twitter-bootstrap-rails', '>= 2.2.3'
end
gem 'jquery-rails'

# Use unicorn as the app server
# gem 'unicorn'
group :production do
  gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara'

  gem 'yard', '~> 0.7.4'
  gem 'yard-rest', git: 'git@github.com:dwaynemac/yard-rest-plugin.git'
end
