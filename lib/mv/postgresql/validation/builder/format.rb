module Mv
  module Postgresql
    module Validation
      module Builder
        class Format < Mv::Core::Validation::Builder::Format
          def apply_with stmt
            "#{stmt} ~ #{db_value(with)}"
          end
        end
      end
    end
  end
end
