require 'spec_helper'

require 'mv/postgresql/validation/base_decorator'

describe Mv::Postgresql::Validation::BaseDecorator do
  before do
    Mv::Core::Validation::Base.send(:prepend, described_class)
  end

  describe "exclusion" do
    subject { Mv::Core::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

    it { is_expected.to be_valid }
    its(:as) { is_expected.to eq(:check)}
  end

  describe "format" do
    subject { Mv::Core::Validation::Format.new(:table_name, :column_name, with: :with) }

    it { is_expected.to be_valid }
    its(:as) { is_expected.to eq(:check)}
  end

  describe "inclusion" do
    subject { Mv::Core::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2]) }

    it { is_expected.to be_valid }
    its(:as) { is_expected.to eq(:check)}
  end

  describe "length" do
    subject { Mv::Core::Validation::Length.new(:table_name, :column_name, in: [1, 2]) }

    it { is_expected.to be_valid }
    its(:as) { is_expected.to eq(:check)}
  end

  describe "presence" do
    subject { Mv::Core::Validation::Presence.new(:table_name, :column_name, {}) }

    it { is_expected.to be_valid }
    its(:as) { is_expected.to eq(:check)}
  end
end