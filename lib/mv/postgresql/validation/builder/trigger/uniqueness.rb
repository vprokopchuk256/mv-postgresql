module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Uniqueness < Mv::Core::Validation::Builder::Uniqueness
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