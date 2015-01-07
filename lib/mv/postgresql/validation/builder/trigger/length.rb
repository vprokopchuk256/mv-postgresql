module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Length < Mv::Core::Validation::Builder::Length
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