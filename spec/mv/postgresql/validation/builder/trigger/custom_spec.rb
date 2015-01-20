require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/custom'

describe Mv::Postgresql::Validation::Builder::Trigger::Custom do
  def custom(opts = {})
    Mv::Postgresql::Validation::Custom.new(:table_name, 
                                           :column_name,
                                           { message: 'some error message' }.merge(opts))
  end

  describe "#conditions" do
    subject { described_class.new(custom(opts)).conditions }

    describe "by default" do
      let(:opts) { { statement: "{column_name} > 0" } }

      it { is_expected.to eq([{
        statement: "NEW.column_name IS NOT NULL AND (NEW.column_name > 0)", 
        message: 'some error message'
      }]) }
    end 
  end
end