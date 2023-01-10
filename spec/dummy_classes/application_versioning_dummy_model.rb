# Exposes some variables/methods that are required to successfully run application versioning tests

class ColumnHashItem
  def type
    :date
  end
end
class ApplicationVersioningDummyModel
  def self.primary_key=(key) end

  def self.table_name
    "dummy"
  end

  def self.columns_hash
    return {"valid_end" => ColumnHashItem.new }
  end

  include MariaDBTemporalTables::ApplicationVersioning
end