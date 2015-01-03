require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Inclusion < Mv::Core::Validation::Inclusion
        include CheckSupport
      end
    end
  end
end