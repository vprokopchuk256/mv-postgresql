module Mv
  module Postgresql
    module Constraint
      module Builder
        class Trigger < Mv::Core::Constraint::Builder::Trigger
          def create
            validation_builders.group_by(&:table_name).each do |table_name, validations|
              db.execute(drop_trigger_statement(table_name))
              db.execute(drop_function_statement())
              db.execute(create_function_statement(table_name))
              db.execute(create_trigger_statement(table_name))
            end
          end

          def delete
            validation_builders.group_by(&:table_name).each do |table_name, validations|
              if db.data_source_exists?(table_name)
                db.execute(drop_trigger_statement(table_name))
                db.execute(drop_function_statement())
              end
            end
          end

          def update new_constraint_builder
            delete
            new_constraint_builder.create
          end

          private

          def func_name
            "#{name}_func"
          end

          def drop_trigger_statement table_name
            "DROP TRIGGER IF EXISTS #{name} ON #{table_name};"
          end

          def create_trigger_statement table_name
            "CREATE TRIGGER #{name} BEFORE #{update? ? 'UPDATE' : 'INSERT'} ON #{table_name}
             FOR EACH ROW EXECUTE PROCEDURE #{func_name}();".squish
          end

          def function_body(table_name)
            validation_builders.select{|b| b.table_name == table_name }.collect(&:conditions).flatten.collect do |condition|
              "IF NOT(#{condition[:statement]}) THEN
                RAISE EXCEPTION '#{condition[:message]}';
              END IF".squish
            end.join("; \n")
          end

          def drop_function_statement
            "DROP FUNCTION IF EXISTS #{func_name}();"
          end

          def create_function_statement table_name
             "CREATE FUNCTION #{func_name}() RETURNS TRIGGER AS $#{func_name}$
                BEGIN
                 #{function_body(table_name)};

                 RETURN NEW;
                END;
              $#{func_name}$ LANGUAGE plpgsql;"
          end
        end
      end
    end
  end
end
