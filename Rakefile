require 'rspec/core'
require 'rspec/core/rake_task'
require 'sequel'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
  spec.rspec_opts = ['--backtrace']
end

task :default => :spec

DATABASE_URL = ENV['DATABASE_URL']

namespace :scrape do

  desc "Hent boligprishistorikk fra nef.no"
  task :nef do
    require File.join(File.dirname(__FILE__), 'util', 'nef_scraper')
    # require 'util/nef_scraper'
    nef_scraper = NefScraper.new(DATABASE_URL)
    nef_scraper.scrape_price_data()
    puts "Screenscraping av nef.no ferdig."
  end

end

namespace :db do
  require "sequel"

  DB = Sequel.connect(DATABASE_URL)

  desc "Start sequel console"
  task :console do
  end

  namespace :migrate do
    Sequel.extension :migration

    desc "Perform migration reset (full erase and migration up)"
    task :reset do
      Sequel::Migrator.run(DB, "db/migrations", :target => 0)
      Sequel::Migrator.run(DB, "db/migrations")
      puts "<= sq:migrate:reset executed"
    end

    desc "Perform migration up/down to VERSION"
    task :to do
      version = ENV['VERSION'].to_i
      raise "No VERSION was provided" if version.nil?
      Sequel::Migrator.run(DB, "db/migrations", :target => version)
      puts "<= sq:migrate:to version=[#{version}] executed"
    end

    desc "Perform migration up to latest migration available"
    task :up do
      Sequel::Migrator.run(DB, "db/migrations")
      puts "<= sq:migrate:up executed"
    end

    desc "Perform migration down (erase all data)"
    task :down do
      Sequel::Migrator.run(DB, "db/migrations", :target => 0)
      puts "<= sq:migrate:down executed"
    end

  end
end
