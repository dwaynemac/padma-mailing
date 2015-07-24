source 'https://rubygems.org'

ruby '1.9.3'

gem 'rails', '~> 3.2.11'
gem 'activity_stream_client', '~> 0.0.11'
gem 'ffi', '~> 1.0.11'

gem 'i18n-js'

gem 'rack-cors'

gem 'logical_model', '~> 0.5.8'
gem 'contacts_client', '~> 0.0.21'
gem 'accounts_client', :github => 'dwaynemac/accounts_client'

gem 'gibbon'
# gem 'mailchimp_client', path: '~/ws/padma/clients/mailchimp_client'
gem 'rails_12factor'

gem 'intercom-rails'

gem 'mercury-rails'

gem 'nokogiri'
gem 'strong_parameters'

# CAS authentication
gem 'devise', '1.5.0'
gem 'devise_cas_authenticatable', '~> 1.3'

# authorization
gem 'cancan'

# Delayed Job
gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem 'liquid'
gem "nested_form"

gem 'padma-assets', '0.1.27'

gem 'rest-client'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem "less-rails"
  gem 'therubyracer', :platforms => :ruby
  gem 'less-rails-bootstrap', '~> 3.0.6'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-fileupload-rails'
end

gem 'jquery-rails'

# Mercury requires paperclip to use the image uploader
gem 'paperclip'

# Using amazon S3 to store the attachments
gem 'aws-sdk'

# Use unicorn as the app server
# gem 'unicorn'
group :production do
  gem 'pg'
  gem 'appsignal', '0.11.9'
end

group :doc do
  gem 'yard', '~> 0.7.4'
  gem 'yard-rest', github: 'dwaynemac/yard-rest-plugin'
end

group :development do
  gem 'git-pivotal-tracker-integration'
  gem 'padma-deployment'
  gem 'debugger'
  gem 'foreman'
  gem 'subcontractor', '0.6.1'
end

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails'
  gem 'shoulda'
  gem 'factory_girl_rails'
  gem 'capybara'
end

group :test do
  gem 'rake'
  gem 'coveralls', require: false
end
