source 'https://rubygems.org'

ruby '2.3.8'

gem 'rails', '~> 4.2'
gem 'ffi', '~> 1.0.11'

gem 'i18n-js'

gem 'rack-cors'

gem 'messaging_client', '~> 0.1'
gem 'activity_stream_client', '0.0.16'
gem 'logical_model', '0.6.6'
gem 'contacts_client', '0.0.54'
gem 'accounts_client', '0.2.38'
gem 'attendance_client', '0.0.4'
gem 'gibbon', '~> 3.1', '>= 3.1.1'
gem 'rails_12factor'

gem 'intercom', '~> 3.7.6'
gem 'intercom-rails'

# gem 'mercury-rails', path: "~/workspace/my_forks/mercury" #git: 'git://github.com/afalkear/mercury.git', branch: 'upgrade-paths'
gem "wysiwyg-rails"

# responders gem for using respond_with
gem 'responders', '~> 2.0'
gem 'sprockets', '3.6.3'

gem 'nokogiri'

# CAS authentication
gem 'devise', '3.4.1'

# authorization
gem 'cancan'

# Delayed Job
gem 'delayed_job_active_record' # must be declared after 'protected_attributes' gem
gem 'liquid'
gem "nested_form"

gem 'padma-assets', '0.2.39'

gem 'rest-client'

gem 'kaminari'

gem 'sass-rails'
gem 'coffee-rails'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem "less-rails"
gem 'therubyracer', :platforms => :ruby
gem 'less-rails-bootstrap', '~> 3.3.5.0'
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
group :production do
  gem 'pg'
end

group :doc do
  gem 'yard', '~> 0.7.4'
  gem 'yard-rest', github: 'dwaynemac/yard-rest-plugin'
end

group :development do
  gem 'git-pivotal-tracker-integration'
  gem 'padma-deployment'
  gem 'debugger2'
  gem 'foreman'
  gem 'subcontractor', '0.6.1'
end

group :development, :test do
  gem 'sqlite3', '~> 1.3.0'
  gem 'rspec-rails', '~> 3.4.0'
  gem 'shoulda'
  gem 'factory_bot_rails'
  gem 'capybara'
end

group :test do
  gem 'rake', '< 12'
  gem 'coveralls', require: false
end
