module ImportData
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/importation_generate.rake"
    end
  end
end
