require 'spec_helper'

describe 'Delete validation scenarios' do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
    ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:prepend, Mv::Postgresql::ActiveRecord::ConnectionAdapters::PostgresqlAdapterDecorator)
    
    Mv::Core::Migration::Base.with_suppressed_validations do
      ActiveRecord::Base.connection.drop_table(:table_name) if ActiveRecord::Base.connection.table_exists?(:table_name)
    end
  end

  describe "change_table" do
    describe "udpate column" do
      before do
        Class.new(::ActiveRecord::Migration) do
          def change
            create_table :table_name, id: false do |t|
              t.string :column_name, validates: { length: { is: 5, as: :trigger, on: :create} } 
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      subject do
         Class.new(::ActiveRecord::Migration) do
          def change
            change_table :table_name, id: false do |t|
              t.change :column_name, :string
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      it "removes migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
      
      it "creates new trigger constraint" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Trigger).to receive(:delete).once
        subject
      end
    end

    describe "remove column" do
      before do
        Class.new(::ActiveRecord::Migration) do
          def change
            create_table :table_name, id: false do |t|
              t.string :column_name_1
              t.string :column_name, validates: { length: { is: 5, as: :trigger, on: :create} } 
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      subject do
         Class.new(::ActiveRecord::Migration) do
          def change
            change_table :table_name, id: false do |t|
              t.remove :column_name
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      it "removes migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
      
      it "creates new trigger constraint" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Trigger).to receive(:delete).once
        subject
      end
    end
  end

  describe "standalone" do
    describe "remove column" do
      before do
        Class.new(::ActiveRecord::Migration) do
          def change
            create_table :table_name, id: false do |t|
              t.string :column_name_1
              t.string :column_name, validates: { length: { is: 5, as: :trigger, on: :create} } 
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      subject do
         Class.new(::ActiveRecord::Migration) do
          def change
            remove_column :table_name, :column_name
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      it "removes migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
      
      it "creates new trigger constraint" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Trigger).to receive(:delete).once
        subject
      end
    end

    describe "update column" do
      before do
        Class.new(::ActiveRecord::Migration) do
          def change
            create_table :table_name, id: false do |t|
              t.string :column_name, validates: { length: { is: 5, as: :trigger, on: :create} } 
            end
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end
      
      subject do
         Class.new(::ActiveRecord::Migration) do
          def change
            change_column :table_name, :column_name, :string, {}
          end
        end.new('TestMigration', '20141118164617').migrate(:up)
      end

      it "removes migration validator" do
        expect{ subject }.to change(Mv::Core::Db::MigrationValidator, :count).by(-1)
      end
      
      it "creates new trigger constraint" do
        expect_any_instance_of(Mv::Core::Constraint::Builder::Trigger).to receive(:delete).once
        subject
      end
    end
  end
end