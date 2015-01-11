require 'spec_helper'

UniquenessTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "uniqueness validation in trigger constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          t.string :uniqueness, validates: { uniqueness: { allow_nil: true, as: :trigger, message: 'uniqueness_error' } }
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)

    UniquenessTestTableName.create!(uniqueness: 'value')
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { UniquenessTestTableName.create! opts }

  describe "with all nulls" do
    let(:opts) { {} }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with all valid values" do
    let(:opts) { { uniqueness: 'some value' } }
    
    it "doesn't raise an error" do
      expect{ subject }.not_to raise_error
    end
  end

  describe "with valid value" do
    let(:opts) { { uniqueness: 'value' } }
    
    it "raises an error with valid message" do
      expect{ subject }.to raise_error.with_message(/uniqueness_error/)
    end
  end
end