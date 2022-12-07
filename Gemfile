source 'https://rubygems.org'

ruby '2.6.8'

gem 'rails', '~> 4.2'

gem 'i18n-js'

gem 'rack-cors'

# Padma Clients
gem 'logical_model', '0.7.1'
gem 'activity_stream_client', '0.1.0'
gem 'contacts_client', '~> 0.1.0'
gem 'accounts_client', '0.3.4'
gem 'messaging_client', '~> 0.3.0'

gem 'padma-assets', '0.3.21'

gem 'attendance_client', '0.0.4'
gem 'gibbon', '~> 3.1', '>= 3.1.1'
gem 'rails_12factor'

# gem 'mercury-rails', path: "~/workspace/my_forks/mercury" #git: 'git://github.com/afalkear/mercury.git', branch: 'upgrade-paths'
gem "wysiwyg-rails"

# responders gem for using respond_with
gem 'responders', '2.4.1'
gem 'sprockets', '4.0.2'

gem 'nokogiri'

# CAS authentication
gem 'devise', '4.4.0'

# authorization
gem 'cancan'

# Delayed Job
gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem "workless", "~> 2.2.0" # requires APP_NAME and WORKLESS_API_KEY in env.

gem 'liquid'
gem "nested_form"

gem 'rest-client'

gem 'kaminari'

gem 'sass-rails'
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem "less-rails"
gem 'therubyracer', :platforms => :ruby
#gem 'less-rails-bootstrap', '~> 3.3.5.0'
gem 'uglifier', '>= 1.0.3'
gem 'jquery-fileupload-rails'

gem 'jquery-rails'

# Mercury requires paperclip to use the image uploader
gem 'paperclip'

# Using amazon S3 to store the attachments
gem 'aws-sdk'

# Use unicorn as the app server
# gem 'unicorn'
gem 'puma'
gem 'appsignal', '~> 2.8'
gem "pg", "0.21"

group :doc do
  gem 'yard', '~> 0.7.4'
  gem 'yard-rest', github: 'dwaynemac/yard-rest-plugin'
end

group :development do
  gem 'git-pivotal-tracker-integration'
  gem 'padma-deployment'
  gem 'foreman'
  gem 'subcontractor', '0.6.1'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.4.0'
  gem 'shoulda'
  gem 'byebug'
  gem 'factory_bot_rails'
  gem 'capybara'
end

group :test do
  gem 'rake', '< 12'
  gem 'coveralls', require: false
end
