require 'spec_helper'

describe Mv::Core::Validation::ActiveModelPresenter::Factory do
  subject(:factory) { described_class }

  describe "#create_presenter" do
    subject { factory.create_presenter(validation) }

    describe "exclusion" do
      let(:validation) { Mv::Postgresql::Validation::Exclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Exclusion) }
    end

    describe "inclusion" do
      let(:validation) { Mv::Postgresql::Validation::Inclusion.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Inclusion) }
    end

    describe "length" do
      let(:validation) { Mv::Postgresql::Validation::Length.new(:table_name, :column_name, in: [1, 2]) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Length) }
    end

    describe "presence" do
      let(:validation) { Mv::Postgresql::Validation::Presence.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Presence) }
    end

    describe "absence" do
      let(:validation) { Mv::Postgresql::Validation::Absence.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Absence) }
    end

    describe "uniqueness" do
      let(:validation) { Mv::Core::Validation::Uniqueness.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Uniqueness) }
    end

    describe "format" do
      let(:validation) { Mv::Postgresql::Validation::Format.new(:table_name, :column_name, {}) }

      it { is_expected.to be_an_instance_of(Mv::Core::Validation::ActiveModelPresenter::Format) }
    end
  end
end
