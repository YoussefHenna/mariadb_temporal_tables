require 'dummy_classes/dummy_author_class'
require 'dummy_classes/combined_versioning_dummy_model'

RSpec.describe "CombinedVersioning" do

  context "application versioning options" do
    # Reset to default options to because other tests rely on default values
    after(:all) { CombinedVersioningDummyModel.application_versioning_options }

    it "should start column name be set from options" do
      start_column_name = "test_start_name"

      CombinedVersioningDummyModel.application_versioning_options :start_column_name => start_column_name

      expect(CombinedVersioningDummyModel.application_versioning_start_column_name).to eq(start_column_name)
    end

    it "should end column name be set from options" do
      end_column_name = "test_end_name"

      CombinedVersioningDummyModel.application_versioning_options :end_column_name => end_column_name

      expect(CombinedVersioningDummyModel.application_versioning_end_column_name).to eq(end_column_name)
    end


    it "should primary key be set from options" do
      primary_key = :some_key
      allow(CombinedVersioningDummyModel).to receive(:primary_key=)

      CombinedVersioningDummyModel.application_versioning_options :primary_key => primary_key

      expect(CombinedVersioningDummyModel).to have_received(:primary_key=).with(primary_key)
    end
  end

  context "system versioning options" do
    # Reset to default options to because other tests rely on default values
    after(:all) { CombinedVersioningDummyModel.system_versioning_options }

    it "should start column name be set from options" do
      start_column_name = "test_start_name"

      CombinedVersioningDummyModel.system_versioning_options :start_column_name => start_column_name

      expect(CombinedVersioningDummyModel.system_versioning_start_column_name).to eq(start_column_name)
    end

    it "should end column name be set from options" do
      end_column_name = "test_end_name"

      CombinedVersioningDummyModel.system_versioning_options :end_column_name => end_column_name

      expect(CombinedVersioningDummyModel.system_versioning_end_column_name).to eq(end_column_name)
    end

    it "should exclude revert be set from options" do
      exclude_revert = [:exclude_one, :exclude_two]

      CombinedVersioningDummyModel.system_versioning_options :exclude_revert => exclude_revert

      expect(CombinedVersioningDummyModel.exclude_revert).to include(*exclude_revert)
    end

    it "should exclude change list be set from options" do
      exclude_change_list = [:exclude_change_one, :exclude_change_two]

      CombinedVersioningDummyModel.system_versioning_options :exclude_change_list => exclude_change_list

      expect(CombinedVersioningDummyModel.exclude_change_list).to include(*exclude_change_list)
    end

    it "should primary key be set from options" do
      primary_key = :some_key
      allow(CombinedVersioningDummyModel).to receive(:primary_key=)

      CombinedVersioningDummyModel.system_versioning_options :primary_key => primary_key

      expect(CombinedVersioningDummyModel).to have_received(:primary_key=).with(primary_key)
    end
  end

  context "all valid at as of" do
    it "should call correct query" do
      allow(CombinedVersioningDummyModel).to receive(:find_by_sql)

      date = Date.today
      time = Time.now
      CombinedVersioningDummyModel.all_valid_at_as_of(date, time)
      expect(CombinedVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE ? BETWEEN valid_start AND valid_end", time, date])
    end
  end

  context "order valid at as of" do
    it "should call correct query" do
      allow(CombinedVersioningDummyModel).to receive(:find_by_sql)

      date = Date.today
      time = Time.now
      CombinedVersioningDummyModel.order_valid_at_as_of(date,time,"DESC", [:first, :second])
      expect(CombinedVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy FOR SYSTEM_TIME AS OF TIMESTAMP? WHERE ? BETWEEN valid_start AND valid_end ORDER BY first, second DESC",time, date])
    end
  end



end