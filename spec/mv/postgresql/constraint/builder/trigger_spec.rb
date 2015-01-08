require 'spec_helper'

require 'mv/postgresql/constraint/builder/trigger'

describe Mv::Postgresql::Constraint::Builder::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
  end

  let(:trigger_description) { Mv::Core::Constraint::Description.new(:idx_mv_table_name, :trigger) }
  let(:trigger_constraint) { Mv::Core::Constraint::Trigger.new(trigger_description) }

  subject(:trigger_builder) { described_class.new(trigger_constraint) }

  describe "#validation_builders" do
    subject { trigger_builder.validation_builders }

    before do
      trigger_constraint.validations << validation
    end

    describe "when exlusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Exclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Exclusion) }
    end

    describe "when inclusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Inclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Inclusion) }
    end

    describe "when length validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Length.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Length) }
    end

    describe "when format validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Format.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Format) }
    end

    describe "when presence validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Presence.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Presence) }
    end

    describe "when uniqueness validation provided" do
      let(:validation) {
        Mv::Core::Validation::Uniqueness.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Uniqueness) }
    end
  end

end