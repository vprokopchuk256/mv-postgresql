require 'spec_helper'

CustomTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "custom validation in trigger constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          t.integer :custom, validates: { custom: { statement: '{custom} > 1', allow_nil: true, as: :trigger, message: 'custom_error' } }
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { CustomTestTableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { {
      custom: 2, 
    } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with valid value" do
    let(:opts) { {
      custom: 1, 
    } }
    
    it "raises an error with valid message" do
      expect{ subject }.to raise_error.with_message(/custom_error/)
    end
  end
end