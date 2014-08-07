
# View helpers
gem 'rails-i18n'
gem 'slim'
gem 'slim-rails'
gem 'homura'
gem 'oj' # Faster JSON

group :development do
  # Use guard to watch files
  gem 'guard'
  gem 'terminal-notifier-guard'

  # Auto run specs
  gem 'guard-rspec'

  # Annotate models
  gem 'annotate', '~> 2.5.0'
  gem 'guard-annotate'

  # Livereload
  gem 'guard-livereload'

  # Make error pages fancy
  gem 'better_errors'
  gem 'binding_of_caller'

  # Open mail in browser
  gem 'letter_opener'

  # Add rspec support for spring
  gem 'spring-commands-rspec', require: false

  # Do not log assets
  gem 'quiet_assets'

  # Restart pow automatically
  gem 'guard-pow'

  # Code analyzer
  gem 'rubocop'
  gem 'guard-rubocop'
end

group :development, :test do
  # Rspec
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
