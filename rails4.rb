source_paths << File.expand_path('..', __FILE__)

# Helpers
def read_file(filename)
  root = File.dirname(rails_template)
  File.read(File.join(root, filename))
end

# Add `rake server`
copy_file 'server.rake', 'lib/tasks/server.rake'

# Add extra gems
append_file 'Gemfile', read_file('extra_gems.rb')
run 'bundle install'

# Setup rspec
run 'mkdir -p spec/support'
copy_file 'spec_helper.rb', 'spec/spec_helper.rb'
copy_file 'mailer_macros.rb', 'spec/support/mailer_macros.rb'
copy_file 'rspec_rc', '.rspec'

# Setup slim
copy_file 'slim.rb', 'config/initializers/slim.rb'

# Setup database
if !options[:skip_active_record]
  gsub_file 'config/database.yml', /_development$/, ''
  gsub_file 'config/database.yml', /_production$/, ''
  gsub_file 'config/database.yml', /username: .+$/, "username: #{ENV['DB_USER'] || 'ayaya'}"
  gsub_file 'config/database.yml', /password: .+$/, "password: #{ENV['DB_PASS']}"
  run 'cp config/database.yml config/database.yml.example'
  append_file '.gitignore', <<-IGNORE_DATABASE.strip_heredoc

  # Ignore database config.
  config/database.yml
  IGNORE_DATABASE
end

# Setup letter opener
insert_into_file 'config/environments/development.rb', <<-LETTER_OPENER, after: "config.assets.debug = true\n"

  # Send mail via letter_opener
  config.action_mailer.delivery_method = :letter_opener
LETTER_OPENER

# Setup homura
remove_file 'app/views/layouts/application.html.erb'
generate 'homura:install'

# Setup guard
run 'guard init annotate rspec livereload'
insert_into_file 'Guardfile', ", all_after_pass: true, all_on_start: true, keep_failed: true, cmd: 'spring rspec'", after: 'guard :rspec'

# Setup spring
copy_file 'spring.rb', 'config/spring.rb'

# Setup app
inject_into_file 'config/application.rb', <<-CONFIG, after: "# config.i18n.default_locale = :de\n"

    # Don't generate helper and asset files with controller
    config.generators.helper = false
    config.generators.assets = false
CONFIG

git :init
git add: '.'
git commit: '-m "initial commit"'
