desc 'Start development server'
task :server do
  exec 'rails server thin -p 3000'
end
