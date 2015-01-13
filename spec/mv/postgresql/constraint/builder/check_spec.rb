require 'spec_helper'

require 'mv/postgresql/constraint/builder/check'

describe Mv::Postgresql::Constraint::Builder::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
    ActiveRecord::Base.connection.drop_table(:table_name) if  ActiveRecord::Base.connection.table_exists?(:table_name) 
    ActiveRecord::Base.connection.create_table(:table_name) do |t|
      t.string :column_name
    end
  end

  describe "#validation_builders" do
    let(:check_description) { Mv::Core::Constraint::Description.new(:chk_table_name_column_name, :check) }
    let(:check_constraint) { Mv::Core::Constraint::Trigger.new(check_description) }

    subject(:check_builder) { described_class.new(check_constraint) }

    subject { check_builder.validation_builders }

    before do
      check_constraint.validations << validation
    end

    describe "when exlusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Exclusion.new(:table_name, :column_name, in: [1, 3], as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Exclusion) }
    end

    describe "when inclusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Inclusion.new(:table_name, :column_name, in: [1, 3], as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Inclusion) }
    end

    describe "when length validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Length.new(:table_name, :column_name, in: [1, 3], as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Core::Validation::Builder::Length) }
    end

    describe "when format validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Format.new(:table_name, :column_name, with: /exp/, as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Format) }
    end

    describe "when presence validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Presence.new(:table_name, :column_name, as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Core::Validation::Builder::Presence) }
    end
  end

  describe "SQL methods" do
    def checks name
      ActiveRecord::Base.connection.select_values("select conname from pg_constraint where contype='c' and conname='#{name}'")
    end

    let(:test_validation_builder_klass) do
      Class.new(Mv::Core::Validation::Builder::Presence) do
        def conditions
          [{ statement: '1 = 1', message: 'some error message' }]
        end
      end
    end

    before do
      Mv::Postgresql::Constraint::Builder::Check.validation_builders_factory.register_builder(
        Mv::Postgresql::Validation::Presence, 
        test_validation_builder_klass
      )
    end

    after do
      Mv::Postgresql::Constraint::Builder::Check.validation_builders_factory.register_builder(
        Mv::Postgresql::Validation::Presence, 
        Mv::Core::Validation::Builder::Presence
      )
    end

    let(:validation) {
      Mv::Postgresql::Validation::Presence.new(:table_name, :column_name, as: :check)
    }


    let(:check_description) { Mv::Core::Constraint::Description.new(:chk_table_name_column_name, :check) }

    let(:check) { Mv::Postgresql::Constraint::Check.new(check_description)}

    before do
      check.validations << validation
      ActiveRecord::Base.connection.execute('ALTER TABLE table_name DROP CONSTRAINT IF EXISTS chk_table_name_column_name;')
    end

    let(:check_builder) { Mv::Postgresql::Constraint::Builder::Check.new(check)}

    describe "#create" do
      subject { check_builder.create }

      describe "when check constraint not yet exist" do
        it "creates new check constraint" do
          expect { subject }.to change{ checks('chk_table_name_column_name').length }.from(0).to(1)
        end
      end

      describe "when check constraint already exist" do
        before do
          ActiveRecord::Base.connection.execute('ALTER TABLE table_name ADD CONSTRAINT chk_table_name_column_name CHECK (1 = 1);')
        end

        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end

      describe "when several validations provided" do
        before do
          check.validations << validation
        end

        it "does not raise an error" do
          expect{ subject }.not_to raise_error
        end
      end
    end

    describe "#update" do
      subject { check_builder.update(check_builder) }

      describe "when check constraint not yet exist" do
        it "creates new check constraint" do
          expect { subject }.to change{ checks('chk_table_name_column_name').length }.from(0).to(1)
        end
      end

      describe "when check constraint already exist" do
        before do
          ActiveRecord::Base.connection.execute('ALTER TABLE table_name ADD CONSTRAINT chk_table_name_column_name CHECK (1 = 1);')
        end

        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end
    end

    describe "#delete" do
      subject { check_builder.delete }

      describe "when check constraint not yet exist" do
        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end

      describe "when table does not exist" do
        before { ActiveRecord::Base.connection.drop_table(:table_name) if  ActiveRecord::Base.connection.table_exists?(:table_name)}
        
        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end

      describe "when check constraint already exist" do
        before do
          ActiveRecord::Base.connection.execute('ALTER TABLE table_name ADD CONSTRAINT chk_table_name_column_name CHECK (1 = 1);')
        end

        it "deletes check constraint" do
          expect { subject }.to change{ checks('chk_table_name_column_name').length }.from(1).to(0)
        end
      end
    end
  end
end