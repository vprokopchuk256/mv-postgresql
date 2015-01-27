require 'spec_helper'

require 'mv/postgresql/validation/builder/trigger/uniqueness'

describe Mv::Postgresql::Validation::Builder::Trigger::Uniqueness do
  def uniqueness(opts = {})
    Mv::Core::Validation::Uniqueness.new(:table_name, 
                                         :column_name,
                                         { message: 'must be unique' }.merge(opts))
  end


  describe "#conditions" do
    subject { described_class.new(uniqueness(opts)).conditions }

    describe "by default" do
      let(:opts) { {} }

      it { is_expected.to eq([{
        statement: "NEW.column_name IS NOT NULL AND NOT EXISTS(SELECT column_name 
                                 FROM table_name 
                                WHERE NEW.column_name = column_name)".squish, 
        message: 'ColumnName must be unique'
      }])}
    end
  end
end