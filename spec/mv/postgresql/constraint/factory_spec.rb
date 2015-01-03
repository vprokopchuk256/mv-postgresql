require 'spec_helper'

describe Mv::Core::Constraint::Factory do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#create_constraint" do
    subject { described_class.create_constraint(description) }

    describe "by default" do
      describe "index" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:index_name, :index) 
        }

        it { is_expected.to be_instance_of(Mv::Postgresql::Constraint::Index) }
      end

      describe "check" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:check_name, :check) 
        }

        it { is_expected.to be_instance_of(Mv::Postgresql::Constraint::Check) }
      end

      describe "trigger" do
        let(:description) { 
          Mv::Core::Constraint::Description.new(:trigger_name, :trigger, event: :create) 
        }

        it { is_expected.to be_instance_of(Mv::Core::Constraint::Trigger) }
      end
    end
  end
end