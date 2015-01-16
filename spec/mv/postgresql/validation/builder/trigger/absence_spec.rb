require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/absence'

describe Mv::Postgresql::Validation::Builder::Trigger::Absence do
  def absence(opts = {})
    Mv::Postgresql::Validation::Absence.new(:table_name, 
                                             :column_name,
                                              { message: 'some error message' }.merge(opts))
  end

  describe "#conditions" do
    subject { described_class.new(absence(opts)).conditions }

    describe "by default" do
      let(:opts) { {} }
       
      it { is_expected.to eq([{
        statement: "NEW.column_name IS NULL OR LENGTH(TRIM(NEW.column_name)) = 0", 
        message: 'some error message'
      }]) }
    end 
  end
end