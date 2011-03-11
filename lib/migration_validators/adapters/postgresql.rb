module MigrationValidators
  module Adapters
    class Postgresql < MigrationValidators::Adapters::Base
      def name
        "PostgreSQL Migration Validators Adapter"
      end

      define_base_syntax
      syntax do
        operation(:regexp) {|stmt, value| "#{stmt} ~ #{value}"}
        operation :db_value do |value|
          case value.class.name
            when "String" then "'#{value}'"
            when "Date" then "'#{value.strftime('%Y-%m-%d')}' "
            when "DateTime" then "'#{value.strftime('%Y-%m-%d %H:%M:%S')}'"
            when "Time" then "'#{value.strftime('%Y-%m-%d %H:%M:%S')}' "
            when "Regexp" then "'#{value.source}'"
            else value.to_s
          end
        end
      end

      define_base_validators

      define_base_containers
      container :insert_trigger do
        operation :create do |stmt, trigger_name, group_name|
          func_name = "#{trigger_name}_func"

          "CREATE OR REPLACE FUNCTION #{func_name}() RETURNS TRIGGER AS $#{func_name}$
             BEGIN
              #{stmt};
              
              RETURN NEW;
             END;
           $#{func_name}$ LANGUAGE plpgsql;

           CREATE TRIGGER #{trigger_name} BEFORE INSERT ON #{group_name.first} 
              FOR EACH ROW EXECUTE PROCEDURE #{func_name}();"
        end

        operation :drop do |stmt, trigger_name, group_name|
          "DROP TRIGGER IF EXISTS #{trigger_name} ON #{group_name.first};"
        end


        operation :bind_to_error do |stmt, error_message|
          "IF NOT(#{stmt}) THEN
            RAISE EXCEPTION '#{error_message}';
           END IF"
        end
      end

      container :update_trigger do
        operation :create do |stmt, trigger_name, group_name|
          func_name = "#{trigger_name}_func"

          "CREATE OR REPLACE FUNCTION #{func_name}() RETURNS TRIGGER AS $#{func_name}$
             BEGIN
              #{stmt};

              RETURN NEW;
             END;
           $#{func_name}$ LANGUAGE plpgsql;

           CREATE TRIGGER #{trigger_name} BEFORE UPDATE ON #{group_name.first} 
              FOR EACH ROW EXECUTE PROCEDURE #{func_name}();"
        end

        operation :drop do |stmt, trigger_name, group_name|
          func_name = "#{trigger_name}_func"

          "DROP TRIGGER IF EXISTS #{trigger_name} ON #{group_name.first};
           DROP FUNCTION IF EXISTS #{func_name}();"
        end

        operation :bind_to_error do |stmt, error_message|
          "IF NOT(#{stmt}) THEN
            RAISE EXCEPTION '#{error_message}';
           END IF"
        end
      end

      container :check do
        operation :drop do |stmt, check_name, group_name|
          "CREATE OR REPLACE FUNCTION __temporary_constraint_drop_function__() RETURNS INTEGER AS $$
              DECLARE 
                constraint_rec RECORD;
              BEGIN
                SELECT INTO constraint_rec * FROM pg_constraint WHERE conname='#{check_name}' AND contype='c';

                IF FOUND THEN
                  ALTER TABLE #{group_name.first} DROP CONSTRAINT #{check_name};
                END IF;

                RETURN 1;
              END;
           $$ LANGUAGE plpgsql;

           SELECT __temporary_constraint_drop_function__();

           DROP FUNCTION __temporary_constraint_drop_function__();
           "
        end
      end


      route :presense, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
      route :presense, :check, :to => :check, :default => true

      route :inclusion, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
      route :inclusion, :check, :to => :check, :default => true

      route :exclusion, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
      route :exclusion, :check, :to => :check, :default => true

      route :length, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
      route :length, :check, :to => :check, :default => true

      route :format, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
      route :format, :check, :to => :check, :default => true

      route :uniqueness, :trigger do
        to :insert_trigger, :if => {:on => [:save, :create, nil]}
        to :update_trigger, :if => {:on => [:save, :update, nil]}
      end
    end

    MigrationValidators.register_adapter! "postgresql", Postgresql
  end
end
