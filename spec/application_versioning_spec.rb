require 'dummy_classes/dummy_author_class'
require 'dummy_classes/application_versioning_dummy_model'

RSpec.describe "ApplicationVersioning" do

  context "options" do
    # Reset to default options to because other tests rely on default values
    after(:all) { ApplicationVersioningDummyModel.application_versioning_options }

    it "should start column name be set from options" do
      start_column_name = "test_start_name"

      ApplicationVersioningDummyModel.application_versioning_options :start_column_name => start_column_name

      expect(ApplicationVersioningDummyModel.application_versioning_start_column_name).to eq(start_column_name)
    end

    it "should end column name be set from options" do
      end_column_name = "test_end_name"

      ApplicationVersioningDummyModel.application_versioning_options :end_column_name => end_column_name

      expect(ApplicationVersioningDummyModel.application_versioning_end_column_name).to eq(end_column_name)
    end


    it "should primary key be set from options" do
      primary_key = :some_key
      allow(ApplicationVersioningDummyModel).to receive(:primary_key=)

      ApplicationVersioningDummyModel.application_versioning_options :primary_key => primary_key

      expect(ApplicationVersioningDummyModel).to have_received(:primary_key=).with(primary_key)
    end
  end

  context "all valid at" do
    it "should call correct query" do
      allow(ApplicationVersioningDummyModel).to receive(:find_by_sql)

      date = Date.today
      ApplicationVersioningDummyModel.all_valid_at(date)
      expect(ApplicationVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy WHERE ? BETWEEN valid_start AND valid_end", date])
    end
  end

  context "order valid at" do
    it "should call correct query" do
      allow(ApplicationVersioningDummyModel).to receive(:find_by_sql)

      date = Date.today
      ApplicationVersioningDummyModel.order_valid_at(date,"DESC", [:first, :second])
      expect(ApplicationVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy WHERE ? BETWEEN valid_start AND valid_end ORDER BY first, second DESC", date])
    end
  end

  context "where valid at" do
    it "should call correct query" do
      allow(ApplicationVersioningDummyModel).to receive(:find_by_sql)

      date = Date.today
      ApplicationVersioningDummyModel.where_valid_at(date,{ :attr => "value1", :attr2 => "value2" })
      expect(ApplicationVersioningDummyModel).to have_received(:find_by_sql).with(["SELECT * FROM dummy WHERE attr = 'value1' AND attr2 = 'value2' AND ? BETWEEN valid_start AND valid_end", date])
    end
  end


end