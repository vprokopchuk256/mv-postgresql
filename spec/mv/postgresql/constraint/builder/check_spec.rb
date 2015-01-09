require 'spec_helper'

require 'mv/postgresql/constraint/builder/check'

describe Mv::Postgresql::Constraint::Builder::Check do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
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
        Mv::Postgresql::Validation::Exclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Exclusion) }
    end

    describe "when inclusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Inclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Inclusion) }
    end

    describe "when length validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Length.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Core::Validation::Builder::Length) }
    end

    describe "when format validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Format.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Format) }
    end

    describe "when presence validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Presence.new(:table_name, 
                                                 :column_name, 
                                                 as: :check)
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Core::Validation::Builder::Presence) }
    end
  end
end