# Exposes some variables/methods that are required to successfully run system versioning tests

class SystemVersioningDummyModel
  def self.primary_key=(key) end

  def self.before_save(*before_save) end

  def self.table_name
    "dummy"
  end

  def self.column_names
    return %w[author_id change_list]
  end

  def id
    1
  end

  def count
    6
  end

  def author_id
    @author_id
  end

  def author_id=(id)
    @author_id = id
  end

  def change_list
    @change_list
  end

  def change_list=(list)
    @change_list = list
  end

  def attributes
    { attr1: "value", attr2: "value2" }
  end

  include MariaDBTemporalTables::SystemVersioning
end