require 'rails'

module MariaDBTemporalTables
  class Railtie < Rails::Railtie
    railtie_name :mariadb_temporal_tables

    rake_tasks do
      path = File.expand_path(__dir__)
      Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
    end
  end
end