module Mv
  module Postgresql
    module Validation
      module ActiveModelPresenter
        class Format < Mv::Core::Validation::ActiveModelPresenter::Base
          def option_names
            super + [:with]
          end

          def validation_name
            :format
          end
        end
      end
    end
  end
end