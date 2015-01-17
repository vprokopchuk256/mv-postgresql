require 'spec_helper'

ExclusionCheckTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "exclusion validation in check constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          ##string
          ###array
          t.string :string_array, validates: { exclusion: { in: ['a', 'b'], allow_nil: true, as: :check}}
          ###range
          t.string :string_range, validates: { exclusion: { in: 'a'..'b', allow_nil: true, as: :check}}

          ##integer
          ###array
          t.integer :integer_array, validates: { exclusion: { in: [1, 3], allow_nil: true, as: :check}}
          ###range
          t.integer :integer_range, validates: { exclusion: { in: 1..3, allow_nil: true, as: :check}}

          ##datetime
          ###array
          t.datetime :datetime_array, validates: { exclusion: { in: [DateTime.new(2011, 1, 1, 1, 1, 1, '+2'), DateTime.new(2012, 2, 2, 2, 2, 2, '+2')], allow_nil: true, as: :check}}
          ###range
          t.datetime :datetime_range, validates: { exclusion: { in: DateTime.new(2011, 1, 1, 1, 1, 1, '+2')..DateTime.new(2012, 2, 2, 2, 2, 2, '+2'), allow_nil: true, as: :check}}

          ##time
          ###array
          t.time :time_array, validates: { exclusion: { in: [Time.new(2011, 1, 1, 1, 1, 1, '+02:00'), Time.new(2012, 2, 2, 2, 2, 2, '+02:00')], allow_nil: true, as: :check}}
          ###range
          t.time :time_range, validates: { exclusion: { in: Time.new(2011, 1, 1, 1, 1, 1, '+02:00')..Time.new(2012, 2, 2, 2, 2, 2, '+02:00'), allow_nil: true, as: :check}}

          ##date
          ###array
          t.date :date_array, validates: { exclusion: { in: [Date.new(2011, 1, 1), Date.new(2012, 2, 2)], allow_nil: true, as: :check}}
          ###range
          t.date :date_range, validates: { exclusion: { in: Date.new(2011, 1, 1)..Date.new(2012, 2, 2), allow_nil: true, as: :check}}

          ##float
          ###array
          t.float :float_array, validates: { exclusion: { in: [1.1, 2.2], allow_nil: true, as: :check}}
          ###range
          t.float :float_range, validates: { exclusion: { in: 1.1..2.2, allow_nil: true, as: :check}}
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { ExclusionCheckTestTableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { {
      string_array: 'c', 
      string_range: 'c', 
      integer_array: 4, 
      integer_range: 4, 
      datetime_array: DateTime.new(2010, 1, 1, 1, 1, 1),
      datetime_range: DateTime.new(2010, 1, 1, 1, 1, 1),
      date_array: Date.new(2010, 1, 1), 
      date_range: Date.new(2010, 1, 2), 
      float_array: 1.0, 
      float_range: 1.0
    } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with invalid" do
    describe "float" do
      describe "array" do
        let(:opts) { { float_array: 1.1 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end

      describe "range" do
        let(:opts) { { float_range: 1.2 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end
    end
    describe "date" do
      describe "array" do
        let(:opts) { { date_array: DateTime.new(2011, 1, 1) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end

      describe "range" do
        let(:opts) { { date_range: DateTime.new(2011, 1, 2) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end
    end
    describe "datetime" do
      describe "array" do
        let(:opts) { { datetime_array: DateTime.new(2011, 1, 1, 1, 1, 1) } }
        
        it "raises an error with valid message" do
          # expect{ subject }.to raise_error        
        end
      end

      describe "range" do
        let(:opts) { { datetime_range: DateTime.new(2011, 1, 1, 1, 1, 2) } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end
    end
    describe "integer" do
      describe "array" do
        let(:opts) { { integer_array: 1 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end

      describe "range" do
        let(:opts) { { integer_range: 2 } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end
    end
    describe "string" do
      describe "array" do
        let(:opts) { { string_array: 'a' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end

      describe "range" do
        let(:opts) { { string_range: 'a' } }
        
        it "raises an error with valid message" do
          expect{ subject }.to raise_error        
        end
      end
    end
  end
end
