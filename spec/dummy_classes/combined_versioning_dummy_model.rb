# Exposes some variables/methods that are required to successfully run combined versioning tests

class CombinedVersioningDummyModel
  def self.primary_key=(key) end

  def self.before_save(*before_save) end

  def self.columns_hash
    return {"valid_end" => ColumnHashItem.new }
  end

  def self.table_name
    "dummy"
  end


  include MariaDBTemporalTables::CombinedVersioning
end