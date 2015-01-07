require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/presence'

describe Mv::Postgresql::Validation::Builder::Trigger::Presence do
  def presence(opts = {})
    Mv::Postgresql::Validation::Presence.new(:table_name, 
                                             :column_name,
                                              { message: 'some error message' }.merge(opts))
  end

  describe "#conditions" do
    subject { described_class.new(presence(opts)).conditions }

    describe "by default" do
      let(:opts) { {} }
       
      it { is_expected.to eq([{
        statement: "NEW.column_name IS NOT NULL AND LENGTH(TRIM(NEW.column_name)) > 0", 
        message: 'some error message'
      }]) }
    end 
  end
end