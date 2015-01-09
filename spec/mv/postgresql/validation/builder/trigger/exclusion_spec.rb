require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/exclusion'

describe Mv::Postgresql::Validation::Builder::Trigger::Exclusion do
  def exclusion(opts = {})
    Mv::Postgresql::Validation::Exclusion.new(:table_name, 
                                              :column_name,
                                              { in: [1, 5], message: 'some error message' }.merge(opts)) 
  end

  describe "#conditions" do
    subject { described_class.new(exclusion(opts)).conditions }

    describe "when dates array passed" do
      let(:opts) { { in: [Date.new(2001, 1, 1), Date.new(2002, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "NEW.column_name IS NOT NULL AND NEW.column_name NOT IN ('2001-01-01', '2002-02-02')", 
        message: 'some error message'
      }]) }
    end
  end
end