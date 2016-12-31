module Mv
  module Postgresql
    module Constraint
      module Builder
        class Check < Mv::Core::Constraint::Builder::Base
          def create
            validation_builders.group_by(&:table_name).each do |table_name, validations|
              db.execute(drop_check_statement(table_name))
              db.execute(create_check_statement(table_name))
            end
          end

          def update new_constraint_builder
            delete
            new_constraint_builder.create
          end

          def delete
            validation_builders.group_by(&:table_name).each do |table_name, validations|
              if db.data_source_exists?(table_name)
                db.execute(drop_check_statement(table_name))
              end
            end
          end

          private

          def check_body(table_name)
            validation_builders.select{|b| b.table_name == table_name }.collect(&:conditions).flatten.collect do |condition|
              "(#{condition[:statement]})"
            end.join(" AND ")
          end

          def create_check_statement(table_name)
            "ALTER TABLE #{table_name} ADD CONSTRAINT #{name} CHECK (#{check_body(table_name)});"
          end

          def drop_check_statement(table_name)
            "ALTER TABLE #{table_name} DROP CONSTRAINT IF EXISTS #{name};"
          end
        end
      end
    end
  end
end
