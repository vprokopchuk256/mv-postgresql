require 'spec_helper'

require 'mv/postgresql/validation/exclusion'
require 'mv/postgresql/validation/builder/exclusion'

describe Mv::Postgresql::Validation::Builder::Exclusion do
  def exclusion(opts = {})
    Mv::Postgresql::Validation::Exclusion.new(:table_name,
                                              :column_name,
                                              { in: [1, 5], message: 'is excluded' }.merge(opts))
  end

  describe "#conditions" do
    subject { described_class.new(exclusion(opts)).conditions }

    describe "when dates array passed" do
      let(:opts) { { in: [Date.new(2001, 1, 1), Date.new(2002, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name NOT IN ('2001-01-01', '2002-02-02')",
        message: 'column_name is excluded'
      }]) }
    end

    describe "when date times array passed" do
      let(:opts) { { in: [DateTime.new(2001, 1, 1, 1, 1, 1), DateTime.new(2002, 2, 2, 2, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name NOT IN ('2001-01-01 01:01:01', '2002-02-02 02:02:02')",
        message: 'column_name is excluded'
      }]) }
    end

    describe "when date times array passed" do
      let(:opts) { { in: [Time.new(2001, 1, 1, 1, 1, 1), Time.new(2002, 2, 2, 2, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name NOT IN ('2001-01-01 01:01:01', '2002-02-02 02:02:02')",
        message: 'column_name is excluded'
      }]) }
    end
  end
end
