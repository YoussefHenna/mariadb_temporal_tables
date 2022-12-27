require_relative "helpers/parser"
require_relative "helpers/migration_generator"

namespace :mariadb_temporal_tables do
  include Parser

  desc "Generates migration for adding application versioning to a table"
  task :gen_migration_application do

    options = parse_options("mariadb_temporal_tables:gen_migration_application")
    table_name = options[:table_name]

    if table_name.nil?
      raise "Missing table parameter to create migration on. Use option --table=table_name to choose a table"
    end

    replace_primary_key = options[:replace_primary_key].nil? ? true : options[:replace_primary_key]
    add_columns = options[:add_columns].nil? ? true : options[:add_columns]
    column_type = options[:column_type] || "DATE"
    start_column_name = options[:start_column_name] || "valid_start"
    end_column_name = options[:end_column_name] || "valid_end"

    unless %w[DATE TIMESTAMP DATETIME].include?(column_type)
      raise "Unsupported column_type provided: #{column_type}"
    end

    migration_name = "add_application_versioning_to_#{table_name.downcase}"
    puts "Generating migration #{migration_name}"

    generator = MigrationGenerator.new
    generator.generate_migration(migration_name,
                                 "application_versioning.rb.erb",
                                 { :replace_primary_key => replace_primary_key,
                                   :add_columns => add_columns,
                                   :column_type => column_type,
                                   :start_column_name => start_column_name,
                                   :end_column_name => end_column_name,
                                   :table_name => table_name
                                 })

    puts "Migration generated successfully"
  end

end
