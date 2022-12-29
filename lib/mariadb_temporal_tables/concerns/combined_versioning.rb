require "active_support/concern"

module MariaDBTemporalTables

  # <tt>ActiveSupport::Concern</tt> that combines the utility of SystemVersioning and ApplicationVersioning
  #
  # <tt>system_versioning_options</tt> and <tt>application_versioning_options</tt> can be called in the model to set options for this concern
  module CombinedVersioning
    extend ActiveSupport::Concern
    include SystemVersioning
    include ApplicationVersioning


    class_methods do

      # Gets all record as of time (system versioning) and valid at time (application versioning)
      # @param [Time, DateTime, Date, String] valid_at used to get records valid at this time
      # @param [Time, String] as_of_time used to get records as of this time
      def all_valid_at_as_of(valid_at, as_of_time)
        parsed_time = parse_time(as_of_time)
        parsed_date = parse_date_or_time(valid_at)
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE ? BETWEEN #{application_versioning_start_column_name} AND #{application_versioning_end_column_name}"
        return find_by_sql [query, parsed_time, parsed_date]
      end

      # Gets all record as of time (system versioning) and valid at time (application versioning) ordered by the given order attributes
      # @param [Time, DateTime, Date, String] valid_at used to get records valid at this time
      # @param [Time, String] as_of_time used to get records as of this time
      # @param [Array<String>, Array<Symbol>] order_attributes list of attributes to order by
      # @return [Array<ActiveRecord::Base>] array of active record objects of the current model ordered
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