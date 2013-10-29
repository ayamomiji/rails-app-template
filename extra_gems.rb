
# View helpers
gem 'rails-i18n'
gem 'slim'
gem 'slim-rails'
gem 'homura'
gem 'oj' # Faster JSON

group :development do
  # Use thin as development server
  gem 'thin'

  # Use guard to watch files
  gem 'guard'
  gem 'rb-fsevent'
  gem 'terminal-notifier-guard'

  # Annotate models
  gem 'guard-annotate'

  # Livereload
  gem 'guard-livereload'

  # Make error pages fancy
  gem 'better_errors'
  gem 'binding_of_caller'

  # Open mail in browser
  gem 'letter_opener'

  # Preload rails
  gem 'spring'
  gem 'spring-commands-rspec', require: false

  # Do not log assets
  gem 'quiet_assets'
end

group :development, :test do
  # Rspec
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'fuubar'
  gem 'database_cleaner'

  # Factory
  gem 'factory_girl_rails'

  # Matchers
  gem 'shoulda-matchers'

  # Helpers
  gem 'timecop'

  # Capybara
  gem 'capybara'
  gem 'poltergeist'
end
