module Mv
  module Postgresql
    module Validation
      module Builder
        class Exclusion < Mv::Core::Validation::Builder::Exclusion
          protected

          def db_value value
            return "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'" if value.is_a?(DateTime)
            return "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'" if value.is_a?(Time)
            return "'#{value.strftime('%Y-%m-%d')}'" if value.is_a?(Date)
            super
          end
        end
      end
    end
  end
end