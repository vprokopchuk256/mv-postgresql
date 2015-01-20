require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Custom < Mv::Core::Validation::Custom
        include CheckSupport
      end
    end
  end
end