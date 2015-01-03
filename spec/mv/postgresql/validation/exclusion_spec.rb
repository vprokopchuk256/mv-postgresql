require 'spec_helper'

require 'mv/postgresql/validation/exclusion'

describe Mv::Postgresql::Validation::Exclusion do
  subject { described_class.new(:table_name, :column_name, in: [1, 2]) }

  it { is_expected.to be_valid }
  its(:as) { is_expected.to eq(:check)}
end