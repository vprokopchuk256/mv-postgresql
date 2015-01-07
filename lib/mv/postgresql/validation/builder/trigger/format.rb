require 'mv/postgresql/validation/builder/format'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Format < Mv::Postgresql::Validation::Builder::Format
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