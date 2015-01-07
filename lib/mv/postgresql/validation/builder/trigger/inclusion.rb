require 'mv/postgresql/validation/builder/inclusion'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Inclusion < Mv::Postgresql::Validation::Builder::Inclusion
            protected 

            def column_reference
              "NEW.#{super}"
            end 
          end
        end
      end
    end
  end
end