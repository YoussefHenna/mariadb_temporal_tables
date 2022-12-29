Gem::Specification.new do |s|
  s.name        = "mariadb_temporal_tables"
  s.version     = "0.1.1"
  s.summary     = "Adds support for MariaDB's temporal tables"
  s.description = "Adds support for MariaDB's System-Versioned tables and Application Time periods into Rails based applications"
  s.authors     = ["Youssef Henna"]
  s.email       = "youssef.hisham14@gmail.com"
  s.files       = ["lib/mariadb_temporal_tables.rb"]
  s.homepage    =
    "https://github.com/YoussefHenna/mariadb_temporal_tables"
  s.license       = "MIT"

  s.add_development_dependency "rails", "~> 7.0.4"
  s.add_development_dependency "simplecov", "~> 0.21.2"
  s.add_development_dependency "minitest", "~> 5.16.3"
  s.add_development_dependency "rake", "~> 13.0.6"

end