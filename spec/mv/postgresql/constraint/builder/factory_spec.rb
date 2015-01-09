require 'spec_helper'

require 'mv/postgresql/constraint/builder/trigger'
require 'mv/postgresql/constraint/builder/check'

describe Mv::Core::Constraint::Builder::Factory do
  describe "#create_builder" do
    subject { described_class.create_builder(constraint) }

    describe "for trigger constraint" do
      let(:trigger_description) { Mv::Core::Constraint::Description.new(:trg_table_name_upd, :trigger, event: :update) }
      let(:constraint) { Mv::Core::Constraint::Trigger.new(trigger_description)}
      
      it { is_expected.to be_a_kind_of(Mv::Postgresql::Constraint::Builder::Trigger) }
    end
    
    describe "for check constraint" do
      let(:check_description) { Mv::Core::Constraint::Description.new(:trg_table_name_upd, :check) }
      let(:constraint) { Mv::Postgresql::Constraint::Check.new(check_description)}
      
      it { is_expected.to be_a_kind_of(Mv::Postgresql::Constraint::Builder::Check) }
    end
  end
end