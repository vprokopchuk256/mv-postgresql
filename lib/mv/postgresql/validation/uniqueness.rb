require 'mv/postgresql/validation/check_support'

module Mv
  module Postgresql
    module Validation
      class Uniqueness < Mv::Core::Validation::Uniqueness
        include CheckSupport

        protected 
        
        def default_as
          :index
        end
      end
    end
  end
end