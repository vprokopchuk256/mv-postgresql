require 'spec_helper'

require 'mv/postgresql/validation/inclusion'

describe Mv::Postgresql::Validation::Inclusion do
  subject { described_class.new(:table_name, :column_name, in: [1, 2]) }

  it { is_expected.to be_valid }
  its(:as) { is_expected.to eq(:check)}
end