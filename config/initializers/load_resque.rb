require 'resque'
require 'resque_scheduler'
require 'resque_scheduler/server'
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'
resque_config = YAML.load_file(File.join(rails_root, 'config/resque.yml'))
Resque.redis = resque_config[rails_env]
#Resque::Scheduler.dynamic = true
Dir[File.join(rails_root,'app','jobs','*.rb')].each { |file| require file }
Resque.schedule = YAML.load_file(File.join(rails_root, 'config/resque_schedule.yml'))