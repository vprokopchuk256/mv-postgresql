require 'spec_helper'

require 'mv/postgresql/validation/format'

describe Mv::Postgresql::Validation::Format do
  subject { described_class.new(:table_name, :column_name, with: :with) }

  it { is_expected.to be_valid }
  its(:as) { is_expected.to eq(:check)}
end