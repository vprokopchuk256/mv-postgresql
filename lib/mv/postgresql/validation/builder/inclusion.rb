module Mv
  module Postgresql
    module Validation
      module Builder
        class Inclusion < Mv::Core::Validation::Builder::Inclusion
          protected

          def db_value value
            return "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'" if value.is_a?(DateTime)
            return "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'" if value.is_a?(Time)
            return "'#{value.strftime('%Y-%m-%d')}'" if value.is_a?(Date)
            return value if value.is_a?(TrueClass) || value.is_a?(FalseClass)
            super
          end
        end
      end
    end
  end
end
