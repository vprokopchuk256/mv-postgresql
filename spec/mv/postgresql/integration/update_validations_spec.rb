require 'spec_helper'

describe 'Update validation scenarios' do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
    ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:prepend, Mv::Postgresql::ActiveRecord::ConnectionAdapters::PostgresqlAdapterDecorator)

    Mv::Core::Migration::Base.with_suppressed_validations do
      ActiveRecord::Base.connection.drop_table(:table_name) if ActiveRecord::Base.connection.table_exists?(:table_name)
    end
  end

  describe 'update column in change_table block' do
    before do
      Class.new(::ActiveRecord::Migration) do
        def change
          create_table :table_name, id: false do |t|
            t.string :column_name, validates: { uniqueness: { as: :trigger, as: :trigger, on: :create } }
          end
        end
      end.new('TestMigration', '20141118164617').migrate(:up)
    end

    subject do
       Class.new(::ActiveRecord::Migration) do
        def change
          change_table :table_name, id: false do |t|
            t.change :column_name, :string, validates: { uniqueness: { as: :index } }
          end
        end
      end.new('TestMigration', '20141118164617').migrate(:up)
    end

    it "deletes trigger constraint" do
      expect_any_instance_of(Mv::Core::Constraint::Trigger).to receive(:delete).once
      subject
    end

    it "creates index constraint" do
      expect_any_instance_of(Mv::Core::Constraint::Index).to receive(:create).once
      subject
    end

    it "updates migration validator" do
      expect{ subject }.to change{Mv::Core::Db::MigrationValidator.first.options}.from(as: :trigger, as: :trigger, on: :create) 
                                                                                  .to(as: :index)
    end
  end

  describe 'standalone update column statement' do
    before do
      Class.new(::ActiveRecord::Migration) do
        def change
          create_table :table_name, id: false do |t|
            t.string :column_name, validates: { uniqueness: { as: :trigger, as: :trigger, on: :create } }
          end
        end
      end.new('TestMigration', '20141118164617').migrate(:up)
    end

    subject do
       Class.new(::ActiveRecord::Migration) do
        def change
          change_column :table_name, :column_name, :string, validates: { uniqueness: { as: :index } }
        end
      end.new('TestMigration', '20141118164617').migrate(:up)
    end

    it "deletes trigger constraint" do
      expect_any_instance_of(Mv::Core::Constraint::Trigger).to receive(:delete).once
      subject
    end

    it "creates index constraint" do
      expect_any_instance_of(Mv::Core::Constraint::Index).to receive(:create).once
      subject
    end

    it "updates migration validator" do
      expect{ subject }.to change{Mv::Core::Db::MigrationValidator.first.options}.from(as: :trigger, as: :trigger, on: :create) 
                                                                                  .to(as: :index)
    end
  end
end