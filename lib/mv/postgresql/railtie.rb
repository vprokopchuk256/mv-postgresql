module Mv
  module Postgresql
    class Railtie < ::Rails::Railtie
      initializer 'mv-postgresql.initialization', after: 'active_record.initialize_database' do
        if defined?(::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) &&
           ::ActiveRecord::Base.connection.is_a?(::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
          require 'mv/postgresql/loader.rb'
        end
      end
    end
  end
end
