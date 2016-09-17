#!/usr/bin/env rake

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'kitchen'
require 'chef-dk/cli'

# Rubocop
desc 'Run Ruby style checks'
RuboCop::RakeTask.new(:rubocop)

# Rspec
desc 'Run ChefSpec examples'
RSpec::Core::RakeTask.new(:spec)

# Integration tests. Kitchen.ci
namespace :integration do
  desc 'Run Test Kitchen with Vagrant'
  task :vagrant do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each do |instance|
      instance.test(:verify)
    end
  end
end

namespace :policyfile do
  desc 'Run "chef update" for Policyfile.rb'
  task :update do
    Dir.glob('test/integration/cookbooks/test/Policyfile.rb').each do |file|
      cli = ChefDK::CLI.new(['update', file])
      subcommand_name, *subcommand_params = cli.argv
      subcommand = cli.instantiate_subcommand(subcommand_name)
      subcommand.run_with_default_options(subcommand_params)
    end
  end
end

# Default
task default: ['rubocop', 'spec', 'policyfile:update', 'integration:vagrant']
