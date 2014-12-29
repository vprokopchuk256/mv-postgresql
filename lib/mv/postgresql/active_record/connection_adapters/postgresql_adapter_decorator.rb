module Mv
  module Postgresql
    module ActiveRecord
      module ConnectionAdapters
        module PostgresqlAdapterDecorator
          include Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
        end
      end
    end
  end
end