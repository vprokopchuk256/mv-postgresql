require 'spec_helper'

require 'mv/postgresql/validation/length'

describe Mv::Postgresql::Validation::Length do
  subject { described_class.new(:table_name, :column_name, in: [1, 5]) }

  it { is_expected.to be_valid }
  its(:as) { is_expected.to eq(:check)}
end