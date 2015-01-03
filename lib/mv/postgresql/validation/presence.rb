require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Presence < Mv::Core::Validation::Presence
        include CheckSupport
      end
    end
  end
end
