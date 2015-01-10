require 'spec_helper'

UniquenessIndexTestTableName = Class.new(ActiveRecord::Base) do
  self.table_name = :table_name
end

describe "uniqueness validation in index constraint begaviour" do
  let(:db) { ActiveRecord::Base.connection }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

    db.drop_table(:table_name) if db.table_exists?(:table_name)

    Class.new(::ActiveRecord::Migration) do
      def change
        create_table :table_name, id: false do |t|
          t.string :uniqueness, validates: { uniqueness: { as: :index } }
        end
      end
    end.new('TestMigration', '20141118164617').migrate(:up)

    UniquenessIndexTestTableName.create!(uniqueness: 'value')
  end

  after { Mv::Core::Db::MigrationValidator.delete_all }

  subject(:insert) { UniquenessIndexTestTableName.create! opts }

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

  describe "with not unique value" do
    let(:opts) { { uniqueness: 'value' } }
    
    it "raises an error with valid message" do
      expect{ subject }.to raise_error
    end
  end
end