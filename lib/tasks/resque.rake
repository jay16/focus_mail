require 'resque'
require 'resque/tasks'
require 'resque_scheduler/tasks'
require 'resque/scheduler'
task "resque:setup" => :environment do
end
task "resque:scheduler_setup" => :environment do
end
task "jobs:work" => "resque:scheduler" do
end
