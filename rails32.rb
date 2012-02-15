remove_file 'README'
remove_file 'public/index.html'
remove_file 'app/assets/images/rails.png'

# Helpers
def read_from_file(filename)
  root = File.dirname(rails_template)
  File.read(File.join(root, filename))
end

def uncomment(file, line)
  gsub_file file, /#\s*#{line}/, line
end

@after_bundle_install = []

def after_bundle_install(&block)
  @after_bundle_install << block
end

# Gemfile
remove_file 'Gemfile'
file 'Gemfile', read_from_file('Gemfile')

# RVM
file '.rvmrc', 'rvm 1.9.3'
append_file '.gitignore', ".rvmrc\n"

# Slim
if yes?('Use Slim? (yes/no)')
  uncomment 'Gemfile', "gem 'slim-rails'"
  after_bundle_install do
    remove_file 'app/views/layouts/application.html.erb'
    file 'app/views/layouts/application.html.slim', read_from_file('application.html.slim')
    gsub_file 'app/views/layouts/application.html.slim', /APP_NAME/, app_name.camelize
  end
end

# Cancan
if yes?('Use Cancan? (yes/no)')
  uncomment 'Gemfile', "gem 'cancan'"
  after_bundle_install do
    generate 'cancan:ability'
    file 'spec/models/ability_spec.rb', read_from_file('ability_spec.rb')
  end
end

# Formtastic
if yes?('Use Simple Form? (yes/no)')
  uncomment 'Gemfile', "gem 'simple_form'"
  after_bundle_install do
    generate 'simple_form:install'
  end
end

# Kaminari
if yes?('Use Kaminari? (yes/no)')
  uncomment 'Gemfile', "gem 'kaminari'"
  after_bundle_install do
    generate 'kaminari:config'
  end
end

# Cells and Draper
if yes?('Use Cells? (yes/no)')
  uncomment 'Gemfile', "gem 'cells'"
  uncomment 'Gemfile', "gem 'rspec-cells'"
end

# Setup database
gsub_file 'config/database.yml', /_development$/, ''
gsub_file 'config/database.yml', /_production$/, ''
gsub_file 'config/database.yml', /username: .+$/, "username: #{ENV['DB_USER'] || 'ayaya'}"
gsub_file 'config/database.yml', /password: .+$/, "password: #{ENV['DB_PASS']}"
rake 'db:create'

# Bundler
run 'bundle install'
@after_bundle_install.each(&:call)

# Application config

inject_into_file 'config/application.rb', <<-CONFIG, :after => "config.assets.version = '1.0'"

    # Don't generate helper and asset files with controller
    config.generators.helper = false
    config.generators.assets = false

    # Don't auto include all helpers
    #config.action_controller.include_all_helpers = false

    Dir['vendor/assets/*'].each do |path|
      config.assets.paths << Rails.root + path
    end
CONFIG

# Rspec, Spork, and Guard
generate 'rspec:install'
append_file '.rspec', '--drb'

append_file 'config/database.yml', <<-SQLITE3

test: # in-memory test
  adapter: sqlite3
  encoding: utf8
  database: ':memory:'
SQLITE3
run 'cp config/database.yml config/database.yml.example'

run 'spork --bootstrap'
remove_file 'spec/spec_helper.rb'
file 'spec/spec_helper.rb', read_from_file('spec_helper.rb')
gsub_file 'spec/spec_helper.rb', /APP_NAME/, app_name.camelize

run 'guard init'
run 'guard init spork'
run 'guard init rspec'

# Annotate
run 'guard init annotate'

# TODO: setup these gems
# * exception_notification
# * whenever
# * dally (session store and cache store in production)

# Quiet assets logging
# http://stackoverflow.com/questions/6312448/how-to-disable-logging-of-asset-pipeline-sprockets-messages-in-rails-3-1
if yes?('Disable assets logging? (yes/no)')
  file 'config/initializers/quiet_assets.rb', read_from_file('quiet_assets.rb')
end

# Git
git :init

append_file '.gitignore', <<-IGNORE_FILES
config/database.yml
public/system/
coverage/
IGNORE_FILES

git :add => '.'
git :commit => '-m "initial commit"'
