require 'mv/postgresql/validation/builder/format'
require 'mv/postgresql/validation/builder/trigger/trigger_column'

module Mv
  module Postgresql
    module Validation
      module Builder
        module Trigger
          class Format < Mv::Postgresql::Validation::Builder::Format
            include TriggerColumn
          end
        end
      end
    end
  end
end