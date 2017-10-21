namespace :importation do
  desc "bundle exec rake importation:generate class_name=ModelName 【validation=true header=true async=false records_per_time=100 async_tool=worker】"
  task :generate do
    puts "importation::generate"
  end
end
