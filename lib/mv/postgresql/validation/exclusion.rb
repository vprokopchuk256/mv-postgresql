require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Exclusion < Mv::Core::Validation::Exclusion
        include CheckSupport
      end
    end
  end
end