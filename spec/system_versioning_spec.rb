require 'dummy_classes/dummy_author_class'
require 'dummy_classes/system_versioning_dummy_model'

RSpec.describe "SystemVersioning" do
  context "versions" do
    it "should call correct query for retrieving versions" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy.class).to receive(:find_by_sql)

      dummy.versions
      expect(dummy.class).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME ALL WHERE id = '1' ORDER BY transaction_end ASC"])
    end

    it "should use ASC by default in query when no order provided" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy.class).to receive(:find_by_sql)

      dummy.versions
      expect(dummy.class).to have_received(:find_by_sql).with([include("ASC")])
    end

    it "should use provided order in query" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy.class).to receive(:find_by_sql)

      dummy.versions("DESC")
      expect(dummy.class).to have_received(:find_by_sql).with([include("DESC")])
    end
  end

  context "revert" do
    it "should call correct query for retrieving version to revert to" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy.class).to receive(:find_by_sql)

      id = 2
      time = Time.now
      dummy.revert(id, time)
      expect(dummy.class).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE id = '#{id}' LIMIT 1", time])
    end

    it "should call update with attributes of found record" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy.class).to receive(:find_by_sql) { [SystemVersioningDummyModel.new] }
      allow(dummy).to receive(:update)

      id = 2
      time = Time.now
      dummy.revert(id, time)
      # Both have same default attributes, check made on original dummy still valid
      expect(dummy).to have_received(:update).with(dummy.attributes)
    end

  end

  context "add author" do
    it "should warning be shown when author not provided" do
      Thread.current[:mariadb_temporal_tables_current_author] = nil

      allow(Warning).to receive(:warn)
      dummy = SystemVersioningDummyModel.new
      dummy.send(:add_author)

      expect(Warning).to have_received(:warn).with("Could not find author to associate with version, make sure to call system_versioning_set_author in your controller")
    end

    it "should author_id be set when author provided" do
      allow(Warning).to receive(:warn)

      dummy_author = DummyAuthorClass.new
      Thread.current[:mariadb_temporal_tables_current_author] = dummy_author

      dummy = SystemVersioningDummyModel.new
      dummy.send(:add_author)

      expect(dummy.author_id).to equal(dummy_author.id)
    end
  end

  context "change list" do
    it "should generate correct change list" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy).to receive(:changes) { { attr1: ["value", "value new"], attr2: ["value2", nil], attr3: [nil, "value3"] } }
      change_list = dummy.send(:get_change_list)

      expect(change_list).to eq("Updated attr1: value -> value new\nRemoved attr2\nAdded attr3: value3\n")
    end

    it "should change_list be set" do
      dummy = SystemVersioningDummyModel.new
      allow(dummy).to receive(:changes) { { attr1: ["value", "value new"], attr2: ["value2", nil], attr3: [nil, "value3"] } }
      dummy.send(:add_change_list)

      expect(dummy.change_list).to eq("Updated attr1: value -> value new\nRemoved attr2\nAdded attr3: value3\n")
    end
  end

  context "options" do
    # Reset to default options to because other tests rely on default values
    after(:all) { SystemVersioningDummyModel.system_versioning_options }

    it "should start column name be set from options" do
      start_column_name = "test_start_name"

      SystemVersioningDummyModel.system_versioning_options :start_column_name => start_column_name

      expect(SystemVersioningDummyModel.system_versioning_start_column_name).to eq(start_column_name)
    end

    it "should end column name be set from options" do
      end_column_name = "test_end_name"

      SystemVersioningDummyModel.system_versioning_options :end_column_name => end_column_name

      expect(SystemVersioningDummyModel.system_versioning_end_column_name).to eq(end_column_name)
    end

    it "should exclude revert be set from options" do
      exclude_revert = [:exclude_one, :exclude_two]

      SystemVersioningDummyModel.system_versioning_options :exclude_revert => exclude_revert

      expect(SystemVersioningDummyModel.exclude_revert).to include(*exclude_revert)
    end

    it "should exclude change list be set from options" do
      exclude_change_list = [:exclude_change_one, :exclude_change_two]

      SystemVersioningDummyModel.system_versioning_options :exclude_change_list => exclude_change_list

      expect(SystemVersioningDummyModel.exclude_change_list).to include(*exclude_change_list)
    end

    it "should primary key be set from options" do
      primary_key = :some_key
      allow(SystemVersioningDummyModel).to receive(:primary_key=)

      SystemVersioningDummyModel.system_versioning_options :primary_key => primary_key

      expect(SystemVersioningDummyModel).to have_received(:primary_key=).with(primary_key)
    end
  end

  context "all as of" do
    it "should call correct query" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql)

      time = Time.now
      SystemVersioningDummyModel.all_as_of(time)
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP?", time])
    end
  end

  context "order as of" do
    it "should call correct query" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql)

      time = Time.now
      SystemVersioningDummyModel.order_as_of(time, "DESC", [:first, :second])
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? ORDER BY first, second DESC", time])
    end
  end

  context "where as of" do
    it "should call correct query" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql)

      time = Time.now
      SystemVersioningDummyModel.where_as_of(time, { :attr => "value1", :attr2 => "value2" })
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE attr = 'value1' AND attr2 = 'value2'", time])
    end
  end

  context "find as of" do
    it "should call correct query" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql) { [SystemVersioningDummyModel.new] }

      id = 5
      time = Time.now
      SystemVersioningDummyModel.find_as_of(time, id)
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE id = '#{id}' LIMIT 1", time])
    end
  end

  context "versions count for author" do
    it "should call correct query" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql) { [SystemVersioningDummyModel.new] }

      id = 5
      SystemVersioningDummyModel.versions_count_for_author(id)
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT COUNT(*) AS count FROM dummy FOR SYSTEM_TIME ALL WHERE author_id=?", id])
    end
  end

  context "composite keys" do
    it "generate where clause using composite key array" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql) { [SystemVersioningDummyModel.new] }

      keys = [:id, :second]
      allow(SystemVersioningDummyModel).to receive(:primary_keys) { keys }

      id = %w[5 value]
      time = Time.now
      SystemVersioningDummyModel.find_as_of(time, id)
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE #{keys[0]}='#{id[0]}' AND #{keys[1]}='#{id[1]}' LIMIT 1", time])
    end

    it "generate where clause using composite key comma seperated string" do
      allow(SystemVersioningDummyModel).to receive(:find_by_sql) { [SystemVersioningDummyModel.new] }

      keys = [:id, :second]
      allow(SystemVersioningDummyModel).to receive(:primary_keys) { keys }

      id = "5,value"
      split = id.split(",")
      time = Time.now
      SystemVersioningDummyModel.find_as_of(time, id)
      expect(SystemVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE #{keys[0]}='#{split[0]}' AND #{keys[1]}='#{split[1]}' LIMIT 1", time])
    end
  end

end