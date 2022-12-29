module MariaDBTemporalTables
  require "mariadb_temporal_tables/railtie" if defined?(Rails)
  require "mariadb_temporal_tables/concerns/system_versioning"
  require "mariadb_temporal_tables/concerns/application_versioning"
  require "mariadb_temporal_tables/concerns/combined_versioning"
end

# Sets the author to be referenced in new versions created on models with system versioning enabled
#
# @param author [Object] Object of author to be referenced when new version is created. Must have 'id' to be referenced.
def system_versioning_set_author(author)
  Thread.current[:mariadb_temporal_tables_current_author] = author
end