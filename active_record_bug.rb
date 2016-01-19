#!/usr/bin/env ruby

require 'bundler/inline'
gemfile(true) do
  source 'https://rubygems.org'
  gem 'activerecord', '4.2.5' # rails/rails@799aedc6437aad61a6355917f625da6fd7868d24 or later
  gem 'pg', '0.18.4'
end

require 'active_record'
require 'active_record/fixtures'
require 'minitest/autorun'
require 'logger'

ActiveRecord::Base.establish_connection adapter: 'postgresql', encoding: 'unicode', database: 'testme', pool: 1, username: 'postgres', host: 'localhost', port: 5432
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :scheduled_trials, force: true do |t|
  end

  create_table :persons_defendants, force: true do |t|
  end

  create_join_table :scheduled_trials, :persons_defendants, table_name: :scheduled_defendants, column_options: {null: true}, force: true do |t|
    t.index [:scheduled_trial_id, :persons_defendant_id], unique: true, name: :scheduled_defendants_index
  end
end

module Persons
  class Defendant < ActiveRecord::Base
    self.table_name = 'persons_defendants'
    has_and_belongs_to_many :scheduled_trials, join_table: :scheduled_defendants, foreign_key: :persons_defendant_id, association_foreign_key: :scheduled_trial_id
  end
end

class ScheduledTrial < ActiveRecord::Base
  has_and_belongs_to_many :defendants, class_name: 'Persons::Defendant', join_table: :scheduled_defendants, foreign_key: :scheduled_trial_id, association_foreign_key: :persons_defendant_id
end

class BugTest < Minitest::Test
  def test_fixtures
    ActiveRecord::FixtureSet.create_fixtures(File.join(File.dirname(__FILE__), 'fixtures'), %w[scheduled_trials persons/defendants], {}, ActiveRecord::Base)
  end
end
