require 'optparse'

# Usage of names arguments in Rake as shown here: http://www.mikeball.us/blog/rake-option-parser/
module Parser
  def parse_options(command)
    options = {}
    option_parser = OptionParser.new
    option_parser.banner = "Usage: rake #{command} [options]"

    case command
    when "mariadb_temporal_tables:gen_migration_application"
      setup_parser_for_gen_migration_application(option_parser, options)
    when "mariadb_temporal_tables:gen_migration_system"
      setup_parser_for_gen_migration_system(option_parser, options)
    else
      raise "Unable to parse options for unknown command: #{command}"
    end

    args = option_parser.order!(ARGV) {}
    option_parser.parse!(args)
    options
  end

  private

  def setup_parser_for_gen_migration_application(parser, options)
    parser.on("--table=TABLE","Table to generate migration for") do |value|
      options[:table_name] = value
    end

    parser.on("--add_columns=ADD","Whether columns should be added to table or not") do |value|
      options[:add_columns] = value == "true"
    end

    parser.on("--start_column_name=NAME","Name of column that represents start of period") do |value|
      options[:start_column_name] = value
    end

    parser.on("--end_column_name=NAME","Name of column that represents end of period") do |value|
      options[:end_column_name] = value
    end

    parser.on("--replace_primary_key=REPLACE","Whether end column should be added to primary key or not") do |value|
      options[:replace_primary_key] = value == "true"
    end

    parser.on("--column_type=TYPE","Type to use for column to be added") do |value|
      options[:column_type] = value
    end
  end

  def setup_parser_for_gen_migration_system(parser, options)
    parser.on("--table=TABLE","Table to generate migration for") do |value|
      options[:table_name] = value
    end

    parser.on("--include_change_list=INC","Whether change_list column should be added or not") do |value|
      options[:include_change_list] = value == "true"
    end

    parser.on("--include_author_reference=INC","Whether reference of author id should be added or not") do |value|
      options[:include_author_reference] = value == "true"
    end

    parser.on("--author_table=TABLE","Table to reference author id from") do |value|
      options[:author_table_name] = value
    end

    parser.on("--start_column_name=NAME","Name of column that represents start of period") do |value|
      options[:start_column_name] = value
    end

    parser.on("--end_column_name=NAME","Name of column that represents end of period") do |value|
      options[:end_column_name] = value
    end

  end

end
