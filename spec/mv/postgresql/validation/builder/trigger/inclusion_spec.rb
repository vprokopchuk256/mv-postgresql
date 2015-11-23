require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/inclusion'

describe Mv::Postgresql::Validation::Builder::Trigger::Inclusion do
  def inclusion(opts = {})
    Mv::Postgresql::Validation::Inclusion.new(:table_name,
                                              :column_name,
                                              { in: [1, 5], message: 'is included' }.merge(opts))
  end

  describe "#conditions" do
    subject { described_class.new(inclusion(opts)).conditions }

    describe "when dates array passed" do
      let(:opts) { { in: [Date.new(2001, 1, 1), Date.new(2002, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "NEW.column_name IS NOT NULL AND NEW.column_name IN ('2001-01-01', '2002-02-02')",
        message: 'column_name is included'
      }]) }
    end
  end
end
