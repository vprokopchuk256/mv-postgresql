module Mv
  module Postgresql
    module Validation
      class Exclusion < Mv::Core::Validation::Exclusion
        def initialize(table_name, column_name, opts)
          super
        end

        protected 
        
        def default_as
          :check 
        end
      end
    end
  end
end