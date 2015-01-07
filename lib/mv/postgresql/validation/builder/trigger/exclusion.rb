require 'mv/postgresql/validation/builder/exclusion'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Exclusion < Mv::Postgresql::Validation::Builder::Exclusion
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