require "active_support/concern"

module MariaDBTemporalTables

  # <tt>ActiveSupport::Concern</tt> that adds methods to the associated model that utilize MariaDB system versioning
  #
  # <tt>system_versioning_options</tt> can be called in the model to set options for this concern
  # See SystemVersioning#system_versioning_options
  module SystemVersioning
    extend ActiveSupport::Concern

    included do
      system_versioning_options # Initialize with default options
      before_save :add_author, :add_change_list

      # Get all the previous versions of this record, including the current version
      # @param [String] order order to be used on the SQL query ("ASC" or "DESC")
      # @return [Array<ActiveRecord::Base>] array of active record objects of the current model
      def versions(order = "ASC")
        where_clause = self.class.generate_where_clause_for_id(self.class.try(:primary_keys), self.id)
        query = "SELECT * FROM #{self.class.table_name} FOR SYSTEM_TIME ALL #{where_clause} ORDER BY #{self.class.system_versioning_end_column_name} #{order}"
        self.class.find_by_sql [query]
      end

      # Revert the current object to a specific version of an object with given id and at the time of end_value
      # @param id [Integer, String, Array<String>] id of the object to revert to
      # @param [Time, String] end_value time at which to revert to
      # @return [true] when successful
      def revert(id, end_value)
        parsed_time = self.class.parse_time(end_value)
        where_clause = self.class.generate_where_clause_for_id(self.class.try(:primary_keys), id)
        query = "SELECT * FROM #{self.class.table_name} FOR SYSTEM_TIME AS OF ? #{where_clause} LIMIT 1"
        query_result = self.class.find_by_sql([query, parsed_time])

        unless query_result
          return false
        end

        revert_object = query_result[0]
        attributes = revert_object.attributes.except(self.class.exclude_revert)
        return self.update(attributes)
      end

      private

      def add_author
        if self.class.column_names.include? "author_id"
          author = Thread.current[:mariadb_temporal_tables_current_author]
          if author
            self.author_id = author.id
          else
            Warning.warn("Could not find author to associate with version, make sure to call system_versioning_set_author in your controller")
          end
        end
      end

      def add_change_list
        if self.class.column_names.include? "change_list"
          change_list = get_change_list
          self.change_list = change_list
        end
      end

      def get_change_list
        change_list = ""
        self.changes.each do |attr_name, change|
          if self.class.exclude_change_list.include? attr_name
            next
          end
          change_text = ""
          old_value = change[0]
          new_value = change[1]

          if is_nil_or_empty(old_value) && !is_nil_or_empty(new_value)
            change_text = "Added #{attr_name}: #{new_value}"
          elsif !is_nil_or_empty(old_value) && is_nil_or_empty(new_value)
            change_text = "Removed #{attr_name}"
          elsif !is_nil_or_empty(old_value) && !is_nil_or_empty(new_value) && old_value != new_value
            change_text = "Updated #{attr_name}: #{old_value} -> #{new_value}"
          else
            next
          end

          change_list += change_text + "\n"
        end
        return change_list
      end

      def is_nil_or_empty(value)
        if value.is_a? String
          return value.nil? || value.empty?
        end
        return value.nil?
      end
    end

    class_methods do
      attr_reader :system_versioning_start_column_name, :system_versioning_end_column_name, :exclude_revert, :exclude_change_list

      # Sets options for system versioning
      # @param [Hash] options the options to use for system versioning
      # @option options [String] :start_column_name the name of the column that indicates start of validity
      # @option options [String] :end_column_name the name of the column that indicates end of validity
      # @option options [Array<String>] :exclude_revert list of column names that should be excluded when reverting a record
      # @option options [Array<String>] :exclude_change_list list of column names that should be excluded when generating the change list
      # @option options [Symbol, Array<Symbol>] :primary_key primary key to be set as the model primary key (can be single or composite key)
      def system_versioning_options(options = {})
        @system_versioning_start_column_name = options[:start_column_name] || "transaction_start"
        @system_versioning_end_column_name = options[:end_column_name] || "transaction_end"

        default_exclude = %w[id author_id change_list]
        @exclude_revert = (options[:exclude_revert] || []) + default_exclude + [@system_versioning_start_column_name, @system_versioning_end_column_name]
        @exclude_change_list = (options[:exclude_change_list] || []) + default_exclude

        self.primary_key = options[:primary_key] || :id
      end

      # Gets all records as of the given time
      # @param [Time, String] as_of_time used to get records as of this time
      def all_as_of(as_of_time)
        parsed_time = parse_time(as_of_time)
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP?"
        return find_by_sql [query, parsed_time]
      end

      # Gets all records as of the given time ordered by the given order attributes
      # @param [Time, String] as_of_time used to get records as of this time
      # @param [String] order order to be used on the SQL query ("ASC" or "DESC")
      # @param [Array<String>, Array<Symbol>] order_attributes list of attributes to order by
      # @return [Array<ActiveRecord::Base>] array of active record objects of the current model ordered
      def order_as_of(as_of_time, order = "ASC", *order_attributes)
        parsed_time = parse_time(as_of_time)
        order_attributes_s = order_attributes.join(", ")
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? ORDER BY #{order_attributes_s} #{order}"
        return find_by_sql [query, parsed_time]
      end

      # Gets all records as of the given time filtered by the given where attributes
      # @param [Time, String] as_of_time used to get records as of this time
      # @param [Hash] where_attributes key-value hash to be used to generate where clause (where key='value' for each)
      # @return [Array<ActiveRecord::Base>] array of active record objects of the current model filtered by attributes
      def where_as_of(as_of_time, where_attributes)
        parsed_time = parse_time(as_of_time)

        where_attributes_s = "WHERE "
        first = true

        where_attributes.each do |attr|
          unless first
            where_attributes_s += " AND "
          end
          first = false

          where_attributes_s += "#{attr[0]} = '#{attr[1]}'"
        end

        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? #{where_attributes_s}"
        return find_by_sql [query, parsed_time]
      end

      # Gets the single records as of the given time with the given id
      # @param [Time, String] as_of_time used to get record as of this time
      # @param [Integer, String, Array<String>] id id of the object to find
      # @return [ActiveRecord::Base] active record object of the found object
      def find_as_of(as_of_time, id)
        parsed_time = parse_time(as_of_time)
        where_clause = generate_where_clause_for_id(try(:primary_keys), id)
        query = "SELECT * FROM #{table_name} FOR SYSTEM_TIME AS OF TIMESTAMP? #{where_clause} LIMIT 1"
        return find_by_sql([query, parsed_time])[0]
      end

      # Gets the number of versions that an author has created. Any version where author_id is equal to the given id
      # @param [Integer, String] author_id id of author
      # @return [Integer] number of versions author has created
      def versions_count_for_author(author_id)
        query = "SELECT COUNT(*) AS count FROM #{table_name} FOR SYSTEM_TIME ALL WHERE author_id=?"
        find_by_sql([query, author_id])[0].count
      end

      def parse_time(time)
        if time.is_a? Time
          return time
        end

        Time.parse(time)
      end

      # In case a composite key is used, this generates where clause considering composite keys
      def generate_where_clause_for_id(primary_keys, id)
        if primary_keys

          unless id.is_a? Array # Composite id could be '1,other_key' or ["1","other_key"]
            id = id.split(",")
          end

          where_clause = "WHERE "
          (0...primary_keys.length).each do |i|
            if i != 0
              where_clause += " AND "
            end
            where_clause += "#{primary_keys[i]}='#{id[i]}'"
          end
          where_clause
        else
          "WHERE id = '#{id}'"
        end
      end

    end

  end
end