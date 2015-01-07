module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          module TriggerColumn
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