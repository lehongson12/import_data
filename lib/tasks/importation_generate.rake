require File.dirname(__FILE__) + "/../import_data/helpers/argument_validation_helper"
include ArgumentValidationHelper

namespace :importation do
  desc "bundle exec rake importation:generate class_name=ModelName 【validation=true header=true async=false records_per_time=100 async_tool=worker】"
  task generate: :environment do
    next unless class_name_valid?(ENV["class_name"]) &&
      async_tool_valid?(ENV["async_tool"]) &&
      boolean_valid?("validation", ENV["validation"]) &&
      boolean_valid?("header", ENV["header"]) &&
      boolean_valid?("async", ENV["async"]) &&
      number_valid?("records_per_time", ENV["records_per_time"])
  end
end
