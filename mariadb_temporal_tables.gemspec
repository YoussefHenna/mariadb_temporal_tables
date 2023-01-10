Gem::Specification.new do |s|
  s.name = "mariadb_temporal_tables"
  s.version = "0.1.3"
  s.summary = "Adds support for MariaDB's temporal tables"
  s.description = "Adds support for MariaDB's System-Versioned tables and Application Time periods into Rails based applications"
  s.authors = ["Youssef Henna"]
  s.email = "youssef.hisham14@gmail.com"
  s.files = ["lib/mariadb_temporal_tables.rb",
             "lib/mariadb_temporal_tables/concerns/application_versioning.rb",
             "lib/mariadb_temporal_tables/concerns/combined_versioning.rb",
             "lib/mariadb_temporal_tables/concerns/system_versioning.rb",
             "lib/mariadb_temporal_tables/railtie.rb",
             "lib/tasks/helpers/migration_generator.rb",
             "lib/tasks/helpers/parser.rb",
             "lib/tasks/migration_templates/application_versioning.rb.erb",
             "lib/tasks/migration_templates/system_versioning.rb.erb",
             "lib/tasks/gen_migration_application.rake",
             "lib/tasks/gen_migration_system.rake"]
  s.homepage =
    "https://github.com/YoussefHenna/mariadb_temporal_tables"
  s.license = "MIT"

  s.add_development_dependency "rails", "~> 7.0.4"
  s.add_development_dependency "simplecov", "~> 0.21.2"
  s.add_development_dependency "rspec", "~> 3.12.0"
  s.add_development_dependency "rake", "~> 13.0.6"
  s.add_development_dependency "rspec-rails", "~> 6.0.1"

end