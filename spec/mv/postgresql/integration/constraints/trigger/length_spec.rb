require 'spec_helper'


LengthTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "length validation in trigger constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          t.string :length_is, validates: { length: { is: 5, allow_nil: true, as: :trigger, message: 'length_is_error' } }
          t.string :length_in_array, validates: { length: { in: [1, 5], allow_nil: true, as: :trigger, message: 'length_in_array_error' } }
          t.string :length_in_range, validates: { length: { in: 1..5, allow_nil: true, as: :trigger, message: 'length_in_range_error' } }
          t.string :length_within_array, validates: { length: { within: [1, 5], allow_nil: true, as: :trigger, message: 'length_within_array_error' } }
          t.string :length_within_range, validates: { length: { within: 1..5, allow_nil: true, as: :trigger, message: 'length_within_range_error' } }
          t.string :length_minimum, validates: { length: { minimum: 5, allow_nil: true, as: :trigger, too_short: 'length_minimum_error' } }
          t.string :length_maximum, validates: { length: { maximum: 5, allow_nil: true, as: :trigger, too_long: 'length_maximum_error' } }
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { LengthTestTableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { {
      length_is: '12345', 
      length_in_array: '1', 
      length_in_range: '1234', 
      length_within_array: '1', 
      length_within_range: '1234', 
      length_minimum: '123456', 
      length_maximum: '1234'
    } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with invalid" do
    describe ":is" do
      let(:opts) { { length_is: '123456' } }
      
      it "raises an error with valid message" do
        expect{ subject }.to raise_error.with_message(/length_is_error/)
      end
    end

    describe ":in" do
      describe "array" do
        let(:opts) { { length_in_array: '1234' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/length_in_array_error/)
        end
      end

      describe "range" do
        let(:opts) { { length_in_range: '123456' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/length_in_range_error/)
        end
      end
    end

    describe ":within" do
      describe "array" do
        let(:opts) { { length_within_array: '1234' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/length_within_array_error/)
        end
      end

      describe "range" do
        let(:opts) { { length_within_range: '123456' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/length_within_range_error/)
        end
      end
    end

    describe ":minimum" do
      let(:opts) { { length_minimum: '1234' } }
      
      it "raises an error with valid message" do
        expect{ subject }.to raise_error.with_message(/length_minimum_error/)
      end
    end

    describe ":maximum" do
      let(:opts) { { length_maximum: '123456' } }
      
      it "raises an error with valid message" do
        expect{ subject }.to raise_error.with_message(/length_maximum_error/)
      end
    end
  end
end