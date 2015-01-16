require 'spec_helper'

require 'mv/postgresql/validation/absence'

describe Mv::Postgresql::Validation::Absence do
  def instance opts = {}
    described_class.new(:table_name, :column_name, opts)
  end

  subject { instance }

  describe "default values" do
    its(:as) { is_expected.to eq(:check)}
    its(:check_name) { is_expected.to eq("chk_mv_table_name_column_name") }
    
    describe ":create_trigger_name" do
      describe "when :as == :check" do
        subject { instance(create_trigger_name: nil, as: :check) }

        its(:create_trigger_name) { is_expected.to be_nil }
      end
    end

    describe ":update_trigger_name" do
      describe "when :as == :check" do
        subject { instance(update_trigger_name: nil, as: :check) }

        its(:update_trigger_name) { is_expected.to be_nil }
      end
    end
  end

  describe "#<==>" do
    it { is_expected.to eq(instance) }
    it { is_expected.not_to eq(instance('check_name' => 'check_name_1')) }
  end
  
  describe "validation" do
    it { is_expected.to be_valid }

    describe ":check_name" do
      describe "when :as == :trigger" do
        subject { instance(update_trigger_name: nil, 
                           create_trigger_name: nil, 
                           check_name: :check_name, 
                           as: :trigger) }
        
        it { is_expected.to be_invalid }
      end
    end

    describe ":on" do
      describe "when :as == :check" do
        subject { instance(on: :create, as: :check, create_trigger_name: nil, update_trigger_name: nil) }
        
        it { is_expected.to be_invalid }
      end 
    end
  end
end