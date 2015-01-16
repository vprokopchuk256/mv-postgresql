require 'spec_helper'

require 'mv/core/validation/factory'

describe Mv::Core::Validation::Factory do
  subject(:factory) { described_class }

  describe "exclusion" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :exclusion, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Exclusion) }
  end

  describe "uniqueness" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :uniqueness, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Core::Validation::Uniqueness) }
  end

  describe "format" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :format, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Format) }
  end

  describe "inclusion" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :inclusion, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Inclusion) }
  end

  describe "length" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :length, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Length) }
  end

  describe "presence" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :presence, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Presence) }
  end

  describe "absence" do
    subject { factory.create_validation(:table_name, 
                                        :column_name, 
                                        :absence, 
                                        { as: :check })}

    it { is_expected.to be_kind_of(Mv::Postgresql::Validation::Absence) }
  end
end