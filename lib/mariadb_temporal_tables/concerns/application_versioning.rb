require "active_support/concern"

module MariaDBTemporalTables
  module ApplicationVersioning
    extend ActiveSupport::Concern

    included do
      application_versioning_options({}) # Initialize with default options
    end

    class_methods do
      attr_reader :application_versioning_start_column_name, :application_versioning_end_column_name

      def application_versioning_options(options)
        @application_versioning_start_column_name = options[:start_column_name] || "valid_start"
        @application_versioning_end_column_name = options[:end_column_name] || "valid_end"

        self.primary_key = options[:primary_key] || [:id, @application_versioning_end_column_name]
      end

      def all_valid_at(valid_at)
        parsed_date = parse_date_or_time(valid_at)
        query = "SELECT * FROM #{table_name} WHERE ? BETWEEN #{@application_versioning_start_column_name} AND #{@application_versioning_end_column_name}"
        return find_by_sql [query, parsed_date]
      end

      def order_valid_at(valid_at, order = "ASC", *order_attributes)
        parsed_date = parse_date_or_time(valid_at)
        order_attributes_s = order_attributes.join(", ")
        query = "SELECT * FROM #{table_name} WHERE ? BETWEEN #{@application_versioning_start_column_name} AND #{@application_versioning_end_column_name} ORDER BY #{order_attributes_s} #{order}"
        return find_by_sql [query, parsed_date]
      end

      def where_valid_at(valid_at, where_attributes)
        parsed_date = parse_date_or_time(valid_at)

        where_attributes_s = "WHERE "
        first = true

        where_attributes.each do |attr|
          unless first
            where_attributes_s += " AND "
          end
          first = false

          where_attributes_s += "#{attr[0]} = '#{attr[1]}'"
        end

        query = "SELECT * FROM #{table_name} #{where_attributes_s} AND ? BETWEEN #{@application_versioning_start_column_name} AND #{@application_versioning_end_column_name}"
        return find_by_sql [query, parsed_date]
      end

      def parse_date_or_time(date_or_time)
        column_type = columns_hash[@application_versioning_end_column_name].type

        case column_type
        when :datetime
          if date_or_time.is_a? DateTime
            return date_or_time
          end

          return DateTime.parse(date_or_time)
        when :timestamp
          if date_or_time.is_a? Time
            return date_or_time
          end

          return Time.parse(date_or_time)
        else
          if date_or_time.is_a? Date
            return date_or_time
          end

          return Date.parse(date_or_time)
        end
      end

    end
  end
end