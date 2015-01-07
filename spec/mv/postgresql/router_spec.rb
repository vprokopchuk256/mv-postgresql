require 'spec_helper'

Description = Mv::Core::Constraint::Description

describe Mv::Core::Router do
  let(:migration_validator) { create(:migration_validator) }

  subject(:router) { described_class }

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "#route" do
    let(:presence) { 
      Mv::Postgresql::Validation::Presence.new(:table_name, :column_name, options) 
    }

    subject { described_class.route(presence) }

    describe "when :as == :check" do
      let(:options) { { as: :check } }

      it { is_expected.to eq([Description.new(presence.check_name, :check)]) }
    end
  end
end   