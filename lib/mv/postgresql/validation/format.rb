require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Format < Mv::Core::Validation::Format
        include CheckSupport
      end
    end
  end
end
