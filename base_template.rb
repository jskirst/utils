# Inspired by https://github.com/RailsApps/rails-composer/blob/master/composer.rb

# 1. Gems
# 2. Database
# 3. Devise
# 4. Procfile
# 5. Unicorn config file
# 6. Bootstrap
# 7. First Model & Scaffold
# 8. Server start.sh
# X. Migrate and start

# Step 1: Gems
gem 'pg'
gem 'devise'
gem 'unicorn'

gem 'debugger'
gem 'binding_of_caller'
gem 'better_errors'
gem 'quiet_assets'

gem 'haml'
gem 'haml-rails'

gem 'therubyracer'
gem 'less-rails'
gem 'twitter-bootstrap-rails'

gem 'jquery-rails'
gem 'sass-rails',   '~> 3.2.3'
gem 'coffee-rails', '~> 3.2.1'
gem 'uglifier', '>= 1.0.3'

# Step 2: Database
remove_file "config/database.yml"
create_file "config/database.yml" do
"development:
  adapter: postgresql
  database: #{app_name}_development
  pool: 5
  username: postgres
  password: 168washu

test:
  adapter: postgresql
  database: #{app_name}_development
  pool: 5
  username: postgres
  password: 168washu

production:
  adapter: postgresql
  database: db/production.postgresql
  pool: 5"
end

# Step 3: Devise
run 'rake db:drop'
run 'rake db:create'

generate 'devise:install'
generate 'devise user'

# Step 4: Procfile
create_file "Procfile" do
  "web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb"
end

# Step 5: Unicorn file
create_file "config/unicorn.rb" do
"
# config/unicorn.rb

worker_processes Integer(ENV['WEB_CONCURRENCY'] || 3)
timeout Integer(ENV['WEB_TIMEOUT'] || 20)
preload_app true

if ENV['RAILS_ENV'] == 'development'
  listen 3000
end

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end  

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
"
end

# Step 6: Bootstrap
generate "bootstrap:install less"

remove_file "app/views/layouts/application.html.erb"
generate "bootstrap:layout application fluid"

# Step 7: First Model
if yes? "Do you want to generate a model?"
  args = ask("supply migration arguments:")
  generate "scaffold #{args}"
  run 'rake db:migrate'
  name = ask("controller name:")
  generate "bootstrap:themed #{name}"
end

# Step 8: Server start.sh
create_file "start.sh" do
  "RACK_ENV=none RAILS_ENV=development unicorn -c config/unicorn.rb"
end

# Final Step: Start and open
run 'sh start.sh'