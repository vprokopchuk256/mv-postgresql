require 'spec_helper'

require 'mv/postgresql/validation/inclusion'
require 'mv/postgresql/validation/builder/inclusion'

describe Mv::Postgresql::Validation::Builder::Inclusion do
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
        statement: "column_name IS NOT NULL AND column_name IN ('2001-01-01', '2002-02-02')", 
        message: 'ColumnName is included'
      }]) }
    end

    describe "when date times array passed" do
      let(:opts) { { in: [DateTime.new(2001, 1, 1, 1, 1, 1), DateTime.new(2002, 2, 2, 2, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name IN ('2001-01-01 01:01:01', '2002-02-02 02:02:02')", 
        message: 'ColumnName is included'
      }]) }
    end

    describe "when date times array passed" do
      let(:opts) { { in: [Time.new(2001, 1, 1, 1, 1, 1), Time.new(2002, 2, 2, 2, 2, 2)] } }

      it { is_expected.to eq([{
        statement: "column_name IS NOT NULL AND column_name IN ('2001-01-01 01:01:01', '2002-02-02 02:02:02')", 
        message: 'ColumnName is included'
      }]) }
    end
  end
end