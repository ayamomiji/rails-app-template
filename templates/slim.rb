# Make Sprockets to compile .slim files in app/assets.
Rails.application.assets.register_engine('.slim', Slim::Template)
