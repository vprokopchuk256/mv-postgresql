require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Absence < Mv::Core::Validation::Absence
        include CheckSupport
      end
    end
  end
end