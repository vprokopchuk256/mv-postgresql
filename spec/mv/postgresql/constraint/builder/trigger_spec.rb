require 'spec_helper'

require 'mv/postgresql/constraint/builder/trigger'

describe Mv::Postgresql::Constraint::Builder::Trigger do
  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    Mv::Core::Db::MigrationValidator.delete_all
  end

  describe "#validation_builders" do
    let(:trigger_description) { Mv::Core::Constraint::Description.new(:trg_mv_table_name, :trigger) }
    let(:trigger_constraint) { Mv::Core::Constraint::Trigger.new(trigger_description) }

    subject(:trigger_builder) { described_class.new(trigger_constraint) }

    subject { trigger_builder.validation_builders }

    before do
      trigger_constraint.validations << validation
    end

    describe "when exlusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Exclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Exclusion) }
    end

    describe "when inclusion validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Inclusion.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Inclusion) }
    end

    describe "when length validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Length.new(:table_name, 
                                                 :column_name, 
                                                 in: [1, 3],
                                                 as: :trigger, 
                                                 update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Length) }
    end

    describe "when format validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Format.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Format) }
    end

    describe "when presence validation provided" do
      let(:validation) {
        Mv::Postgresql::Validation::Presence.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Presence) }
    end

    describe "when uniqueness validation provided" do
      let(:validation) {
        Mv::Core::Validation::Uniqueness.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name) 
      }

      its(:first) { is_expected.to be_a_kind_of(Mv::Postgresql::Validation::Builder::Trigger::Uniqueness) }
    end
  end

  describe "SQL methods" do
    def triggers name
      ActiveRecord::Base.connection.select_values("select tgname from pg_trigger where tgname = '#{name}'")
    end

    def procs name
      ActiveRecord::Base.connection.select_values("select proname from pg_proc where proname = '#{name}'")
    end

    before do
      Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
        Mv::Postgresql::Validation::Presence, 
        test_validation_builder_klass
      )
    end

    after do
      Mv::Postgresql::Constraint::Builder::Trigger.validation_builders_factory.register_builder(
        Mv::Postgresql::Validation::Presence, 
        Mv::Postgresql::Validation::Builder::Trigger::Presence
      )
    end

    let(:validation) {
      Mv::Postgresql::Validation::Presence.new(:table_name, 
                                               :column_name, 
                                               with: /exp/,
                                               as: :trigger, 
                                               update_trigger_name: :trg_mv_table_name_upd, 
                                               create_trigger_name: :trg_mv_table_name_ins) 
    }

    let(:test_validation_builder_klass) do
      Class.new(Mv::Postgresql::Validation::Builder::Trigger::Presence) do
        def conditions
          [{ statement: '1 = 1', message: 'some error message' }]
        end
      end
    end

    let(:create_trigger_description) { Mv::Core::Constraint::Description.new(:trg_mv_table_name_ins, :trigger, event: :create) }
    let(:update_trigger_description) { Mv::Core::Constraint::Description.new(:trg_mv_table_name_upd, :trigger, event: :update) }

    let(:create_trigger) { Mv::Core::Constraint::Trigger.new(create_trigger_description)}
    let(:update_trigger) { Mv::Core::Constraint::Trigger.new(update_trigger_description)}

    before do
      create_trigger.validations << validation
      update_trigger.validations << validation
      ActiveRecord::Base.connection.execute('DROP TRIGGER IF EXISTS trg_mv_table_name_ins ON table_name;')
      ActiveRecord::Base.connection.execute('DROP FUNCTION IF EXISTS trg_mv_table_name_ins_func();')
    end

    let(:create_trigger_builder) { Mv::Postgresql::Constraint::Builder::Trigger.new(create_trigger)}
    let(:update_trigger_builder) { Mv::Postgresql::Constraint::Builder::Trigger.new(update_trigger)}

    describe "#create" do
      subject { create_trigger_builder.create }

      describe "when both trigger and trigger function do not exist" do
        it "creates new trigger" do
          expect { subject }.to change{ triggers('trg_mv_table_name_ins').length }.from(0).to(1)
        end

        it "create new trigger function" do
          expect { subject }.to change{ procs('trg_mv_table_name_ins_func').length }.from(0).to(1)
        end
      end

      describe "when function exists but trigger does not" do
        before do 
          ActiveRecord::Base.connection.execute(
             "CREATE FUNCTION trg_mv_table_name_ins_func() RETURNS TRIGGER AS $trg_mv_table_name_ins_func$
                BEGIN
                  IF NOT(1 = 1) THEN
                    RAISE EXCEPTION 'some error exception';
                  END IF;
                
                  RETURN NEW;
                END;
              $trg_mv_table_name_ins_func$ LANGUAGE plpgsql;"
          )
        end

        it "creates new trigger" do
          expect { subject }.to change{ triggers('trg_mv_table_name_ins').length }.from(0).to(1)
        end
      end
    end

    describe "#update" do
      subject { create_trigger_builder.update(create_trigger_builder) }

      describe "when both trigger and trigger function exist" do
        before do 
          ActiveRecord::Base.connection.execute(
             "CREATE FUNCTION trg_mv_table_name_ins_func() RETURNS TRIGGER AS $trg_mv_table_name_ins_func$
                BEGIN
                  IF NOT(1 = 1) THEN
                    RAISE EXCEPTION 'some error exception';
                  END IF;
                
                  RETURN NEW;
                END;
              $trg_mv_table_name_ins_func$ LANGUAGE plpgsql;"
          )
          ActiveRecord::Base.connection.execute(
           "CREATE TRIGGER trg_mv_table_name_ins 
              BEFORE INSERT ON table_name
              FOR EACH ROW EXECUTE PROCEDURE trg_mv_table_name_ins_func();"
          )
        end

        it "does not raise an error" do
          expect { subject }.not_to raise_error
        end
      end

      describe "when function exists but trigger does not" do
        before do 
          ActiveRecord::Base.connection.execute(
             "CREATE FUNCTION trg_mv_table_name_ins_func() RETURNS TRIGGER AS $trg_mv_table_name_ins_func$
                BEGIN
                  IF NOT(1 = 1) THEN
                    RAISE EXCEPTION 'some error exception';
                  END IF;
                
                  RETURN NEW;
                END;
              $trg_mv_table_name_ins_func$ LANGUAGE plpgsql;"
          )
        end

        it "creates new trigger" do
          expect { subject }.to change{ triggers('trg_mv_table_name_ins').length }.from(0).to(1)
        end
      end
    end

    describe "#delete" do
      subject { create_trigger_builder.delete }

      describe "when both trigger and trigger function exist" do
        before do 
          ActiveRecord::Base.connection.execute(
             "CREATE FUNCTION trg_mv_table_name_ins_func() RETURNS TRIGGER AS $trg_mv_table_name_ins_func$
                BEGIN
                  IF NOT(1 = 1) THEN
                    RAISE EXCEPTION 'some error exception';
                  END IF;
                
                  RETURN NEW;
                END;
              $trg_mv_table_name_ins_func$ LANGUAGE plpgsql;"
          )
          ActiveRecord::Base.connection.execute(
           "CREATE TRIGGER trg_mv_table_name_ins 
              BEFORE INSERT ON table_name
              FOR EACH ROW EXECUTE PROCEDURE trg_mv_table_name_ins_func();"
          )
        end

        it "deletes trigger" do
          expect { subject }.to change{ triggers('trg_mv_table_name_ins').length }.from(1).to(0)
        end

        it "deletes trigger function" do
          expect { subject }.to change{ procs('trg_mv_table_name_ins_func').length }.from(1).to(0)
        end
      end

      describe "when function exists but trigger does not" do
        before do 
          ActiveRecord::Base.connection.execute(
             "CREATE FUNCTION trg_mv_table_name_ins_func() RETURNS TRIGGER AS $trg_mv_table_name_ins_func$
                BEGIN
                  IF NOT(1 = 1) THEN
                    RAISE EXCEPTION 'some error exception';
                  END IF;
                
                  RETURN NEW;
                END;
              $trg_mv_table_name_ins_func$ LANGUAGE plpgsql;"
          )
        end

        it "deletes trigger function" do
          expect { subject }.to change{ procs('trg_mv_table_name_ins_func').length }.from(1).to(0)
        end
      end
    end
  end
end