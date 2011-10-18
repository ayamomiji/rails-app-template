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
file '.rvmrc', 'rvm 1.9.2'
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
if yes?('Use Formtastic? (yes/no)')
  uncomment 'Gemfile', "gem 'formtastic'"
  after_bundle_install do
    generate 'formtastic:install'
    inject_into_file 'app/assets/stylesheets/application.css', " *= require formtastic\n", :before => ' *= require_self'
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
if yes?('Use Cells and Draper? (yes/no)')
  uncomment 'Gemfile', "gem 'cells'"
  uncomment 'Gemfile', "gem 'rspec-cells'"
  uncomment 'Gemfile', "gem 'draper'"
end

# Bundler
run 'bundle install'
@after_bundle_install.each(&:call)

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

file 'spec/factories.rb', <<-FACTORIES
FactoryGirl.define do
  # Add your factories here, for example:
  #
  #sequence(:username) { |n| "username-\#{n}" }
  #sequence(:password) { SecureRandom.hex(30) }
  #
  #factory :user do
  #  username { Factory.next(:username) }
  #  password { Factory.next(:password) }
  #
  #  factory :admin do
  #    admin true
  #  end
  #end
end
FACTORIES

# Annotate
run 'guard init annotate'

# TODO: setup these gems
# * exception_notification
# * whenever
# * paperclip (spec helper)
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
