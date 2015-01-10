require 'spec_helper'

FormatTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "format validation in trigger constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          t.string :format_string, validates: { format: { with: 'value', allow_nil: true, as: :trigger, message: 'format_string' } }
          t.string :format_regexp, validates: { format: { with: /value/, allow_nil: true, as: :trigger, message: 'format_regexp' } }
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { FormatTestTableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { {
      format_string: 'some value', 
      format_regexp: 'some value'
    } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with invalid" do
    describe "string" do
      let(:opts) { { format_string: 'some string' } }
      
      it "raises an error with valid message" do
        expect{ subject }.to raise_error.with_message(/format_string/)
      end
    end

    describe "regexp" do
      let(:opts) { { format_regexp: 'some string' } }
      
      it "raises an error with valid message" do
        expect{ subject }.to raise_error.with_message(/format_regexp/)
      end
    end
  end
end