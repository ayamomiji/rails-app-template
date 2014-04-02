source_paths << File.expand_path('..', __FILE__)

# Helpers
def read(filename)
  root = File.dirname(rails_template)
  File.read(File.join(root, filename))
end

# Questions
use_bootstrap = yes? 'Use Bootstrap? (y/n)'
generate_default_index_page = yes? 'Generate default index page? (y/n)' if use_bootstrap

# Use unicorn as development server
gsub_file 'Gemfile', "# gem 'unicorn'", read('templates/unicorn/gems.rb').chomp
remove_file 'config.ru'
copy_file 'templates/unicorn/config.ru', 'config.ru'
copy_file 'templates/unicorn/config.rb', 'config/unicorn/staging.rb'
copy_file 'templates/unicorn/config.rb', 'config/unicorn/production.rb'

# Add extra gems
append_file 'Gemfile', read('templates/extra_gems.rb')
if use_bootstrap
  inject_into_file 'Gemfile', read('templates/bootstrap/gems.rb'), after: /gem 'sass-rails', '.+'\n/
end
run 'bundle install'

# Silence I18n deprecation warning
copy_file 'templates/i18n.rb', 'config/initializers/i18n.rb'

# Setup rspec
run 'mkdir -p spec/support'
copy_file 'templates/spec_helper.rb', 'spec/spec_helper.rb'
copy_file 'templates/mailer_macros.rb', 'spec/support/mailer_macros.rb'
copy_file 'templates/rspec_rc', '.rspec'

# Setup slim
copy_file 'templates/slim.rb', 'config/initializers/slim.rb'

# Setup database
if !options[:skip_active_record]
  gsub_file 'config/database.yml', /_development$/, ''
  gsub_file 'config/database.yml', /_production$/, ''
  gsub_file 'config/database.yml', /username: .+$/, "username: #{ENV['DB_USER'] || 'ayaya'}"
  gsub_file 'config/database.yml', /password: .+$/, "password: #{ENV['DB_PASS']}"
  run 'cp config/database.yml config/database.yml.example'
  append_file '.gitignore', read('templates/gitignore')
end

# Setup letter opener
insert_into_file 'config/environments/development.rb', read('templates/letter_opener.rb'), after: "config.assets.debug = true\n"

# Setup homura
remove_file 'app/views/layouts/application.html.erb'
generate 'homura:install'

# Setup guard
run 'guard init annotate rspec livereload pow'
insert_into_file 'Guardfile', ", all_after_pass: true, all_on_start: true, cmd: 'spring rspec'", after: 'guard :rspec'

# Setup spring
copy_file 'templates/spring.rb', 'config/spring.rb'

# Setup app
inject_into_file 'config/application.rb', read('templates/disable_generators.rb'), after: "# config.i18n.default_locale = :de\n"

# Use SCSS for application
copy_file 'templates/application.css.scss', 'app/assets/stylesheets/application.css.scss'
remove_file 'app/assets/stylesheets/application.css'

if use_bootstrap
  inject_into_file 'app/assets/stylesheets/application.css.scss', read('templates/bootstrap/css.scss'), after: '*/'

  if generate_default_index_page
    generate 'controller', 'pages'
    inject_into_file 'config/routes.rb', "  root to: 'pages#index'\n", after: "draw do\n"
    file 'app/views/pages/index.html.slim', ''
  end
end

git :init
git add: '.'
git commit: '-m "initial commit"'
