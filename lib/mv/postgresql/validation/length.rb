require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Length < Mv::Core::Validation::Length
        include CheckSupport
      end
    end
  end
end