require 'spec_helper'

TableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "inclusion validation in trigger constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          ##string
          ###array
          t.string :inclusion_string_array, validates: { inclusion: { in: ['a', 'b'], allow_nil: true, as: :trigger, message: 'inclusion_string_array' }}
          ###range
          t.string :inclusion_string_range, validates: { inclusion: { in: 'a'..'b', allow_nil: true, as: :trigger, message: 'inclusion_string_range' }}

          ##integer
          ###array
          t.integer :inclusion_integer_array, validates: { inclusion: { in: [1, 3], allow_nil: true, as: :trigger, message: 'inclusion_integer_array' }}
          ###range
          t.integer :inclusion_integer_range, validates: { inclusion: { in: 1..3, allow_nil: true, as: :trigger, message: 'inclusion_integer_range' }}

          ##datetime
          ###array
          t.datetime :inclusion_datetime_array, validates: { inclusion: { in: [DateTime.new(2011, 1, 1, 1, 1, 1, '+2'), DateTime.new(2012, 2, 2, 2, 2, 2, '+2')], allow_nil: true, as: :trigger, message: 'inclusion_datetime_array' }}
          ###range
          t.datetime :inclusion_datetime_range, validates: { inclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1, '+2')..DateTime.new(2012, 2, 2, 2, 2, 2, '+2'), allow_nil: true, as: :trigger, message: 'inclusion_datetime_range' }}

          ##time
          ###array
          t.time :inclusion_time_array, validates: { inclusion: { in: [Time.new(2011, 1, 1, 1, 1, 1, '+02:00'), Time.new(2012, 2, 2, 2, 2, 2, '+02:00')], allow_nil: true, as: :trigger, message: 'inclusion_time_array' }}
          ###range
          t.time :inclusion_time_range, validates: { inclusion: { in: Time.new(2011, 1, 1, 1, 1, 1, '+02:00')..Time.new(2012, 2, 2, 2, 2, 2, '+02:00'), allow_nil: true, as: :trigger, message: 'inclusion_time_range' }}

          ##date
          ###array
          t.date :inclusion_date_array, validates: { inclusion: { in: [Date.new(2011, 1, 1), Date.new(2012, 2, 2)], allow_nil: true, as: :trigger, message: 'inclusion_date_array' }}
          ###range
          t.date :inclusion_date_range, validates: { inclusion: { in: Date.new(2011, 1, 1)..Date.new(2012, 2, 2), allow_nil: true, as: :trigger, message: 'inclusion_date_range' }}

          ##float
          ###array
          t.float :inclusion_float_array, validates: { inclusion: { in: [1.1, 2.2], allow_nil: true, as: :trigger, message: 'inclusion_float_array' }}
          ###range
          t.float :inclusion_float_range, validates: { inclusion: { in: 1.1..2.2, allow_nil: true, as: :trigger, message: 'inclusion_float_range' }}
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { TableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { {
      inclusion_string_array: 'a', 
      inclusion_string_range: 'a', 
      inclusion_integer_array: 1, 
      inclusion_integer_range: 1, 
      inclusion_datetime_array: DateTime.new(2011, 1, 1, 1, 1, 1),
      inclusion_datetime_range: DateTime.new(2011, 1, 1, 1, 1, 2),
      inclusion_date_array: Date.new(2011, 1, 1), 
      inclusion_date_range: Date.new(2011, 1, 2), 
      inclusion_float_array: 1.1, 
      inclusion_float_range: 1.2
    } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end

  end

  describe "with invalid" do
    describe "float" do
      describe "array" do
        let(:opts) { { inclusion_float_array: 1.0 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_float_array/)
        end
      end

      describe "range" do
        let(:opts) { { inclusion_float_range: 1.0 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_float_range/)
        end
      end
    end
    describe "date" do
      describe "array" do
        let(:opts) { { inclusion_date_array: DateTime.new(2010, 1, 1) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_date_array/)
        end
      end

      describe "range" do
        let(:opts) { { inclusion_date_range: DateTime.new(2010, 1, 1) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_date_range/)
        end
      end
    end
    describe "datetime" do
      describe "array" do
        let(:opts) { { inclusion_datetime_array: DateTime.new(2010, 1, 1, 1, 1, 1) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_datetime_array/)
        end
      end

      describe "range" do
        let(:opts) { { inclusion_datetime_range: DateTime.new(2010, 1, 1, 1, 1, 1) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_datetime_range/)
        end
      end
    end
    describe "integer" do
      describe "array" do
        let(:opts) { { inclusion_integer_array: 4 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_integer_array/)
        end
      end

      describe "range" do
        let(:opts) { { inclusion_integer_range: 4 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_integer_range/)
        end
      end
    end
    describe "string" do
      describe "array" do
        let(:opts) { { inclusion_string_array: 'c' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_string_array/)
        end
      end

      describe "range" do
        let(:opts) { { inclusion_string_range: 'c' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error.with_message(/inclusion_string_range/)
        end
      end
    end
  end
end
