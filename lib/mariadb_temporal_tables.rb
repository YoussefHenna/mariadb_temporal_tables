module MariaDBTemporalTables
  require "mariadb_temporal_tables/railtie" if defined?(Rails)
  require "mariadb_temporal_tables/concerns/system_versioning"
  require "mariadb_temporal_tables/concerns/application_versioning"
  require "mariadb_temporal_tables/concerns/combined_versioning"

  def system_versioning_set_author(author)
    Thread.current[:mariadb_temporal_tables_current_author] = author
  end

end