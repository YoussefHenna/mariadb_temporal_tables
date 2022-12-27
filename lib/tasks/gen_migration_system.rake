require_relative "helpers/parser"
require_relative "helpers/migration_generator"

namespace :mariadb_temporal_tables do
  include Parser

  desc "Generates migration for adding system versioning to a table"
  task :gen_migration_system do

    options = parse_options("mariadb_temporal_tables:gen_migration_system")
    table_name = options[:table_name]

    if table_name.nil?
      raise "Missing table parameter to create migration on. Use option --table=table_name to choose a table"
    end

    include_change_list = options[:include_change_list].nil? ? false : options[:include_change_list]
    include_author_reference = options[:include_author_reference].nil? ? false : options[:include_author_reference]
    author_table_name = options[:author_table_name] || "users"
    start_column_name = options[:start_column_name] || "transaction_start"
    end_column_name = options[:end_column_name] || "transaction_end"

    migration_name = "add_system_versioning_to_#{table_name.downcase}"
    puts "Generating migration #{migration_name}"

    generator = MigrationGenerator.new
    generator.generate_migration(migration_name,
                                 "system_versioning.rb.erb",
                                 { :include_change_list => include_change_list,
                                   :include_author_reference => include_author_reference,
                                   :author_table_name => author_table_name,
                                   :start_column_name => start_column_name,
                                   :end_column_name => end_column_name,
                                   :table_name => table_name
                                 })

    puts "Migration generated successfully"
  end

end
