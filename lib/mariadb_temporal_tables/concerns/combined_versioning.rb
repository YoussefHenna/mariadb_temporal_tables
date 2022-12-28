require "active_support/concern"

module MariaDBTemporalTables
  module CombinedVersioning
    extend ActiveSupport::Concern
    include SystemVersioning
    include ApplicationVersioning


    class_methods do
      def all_valid_at_as_of(valid_at, as_of_time)
        parsed_time = parse_time(as_of_time)
        parsed_date = parse_date_or_time(valid_at)
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE ? BETWEEN #{application_versioning_start_column_name} AND #{application_versioning_end_column_name}"
        return find_by_sql [query, parsed_time, parsed_date]
      end

      def order_valid_at_as_of(valid_at, as_of_time, order="ASC", *order_attributes)
        parsed_time = parse_time(as_of_time)
        parsed_date = parse_date_or_time(valid_at)
        order_attributes_s = order_attributes.join(", ")
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE ? BETWEEN #{application_versioning_start_column_name} AND #{application_versioning_end_column_name} ORDER BY #{order_attributes_s} #{order}"
        return find_by_sql [query, parsed_time, parsed_date]
      end
    end

  end
end