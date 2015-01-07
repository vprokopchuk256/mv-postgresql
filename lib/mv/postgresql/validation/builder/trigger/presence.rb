module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Presence < Mv::Core::Validation::Builder::Presence
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