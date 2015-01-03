require 'spec_helper'

require 'mv/postgresql/validation/presence'

describe Mv::Postgresql::Validation::Presence do
  subject { described_class.new(:table_name, :column_name, {}) }

  it { is_expected.to be_valid }
  its(:as) { is_expected.to eq(:check)}
end