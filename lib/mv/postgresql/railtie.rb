require 'mv/postgresql/active_record/connection_adapters/postgresql_adapter_decorator'

module Mv
  module Postgresql
    class Railtie < ::Rails::Railtie
      initializer 'mv-postgresql.initialization', after: 'active_record.initialize_database' do
        ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:prepend, Mv::Postgresql::ActiveRecord::ConnectionAdapters::PostgresqlAdapterDecorator)
      end
    end
  end
end