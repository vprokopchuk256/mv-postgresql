module Mv
  module Postgresql
    module Validation
      class Inclusion < Mv::Core::Validation::Inclusion
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