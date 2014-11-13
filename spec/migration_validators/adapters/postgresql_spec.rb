require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Adapters::Postgresql, :type => :mv_test do
  before :all do
    Driver = Class.new(MigrationValidators::Adapters::Base)
    use_db :adapter => "postgresql",  
           :database => "validation_migration_test_db", 
           :username => "postgres"

    db.initialize_migration_validators_table
    ::ActiveRecord::Migration.verbose = false
  end

  before :each do
    MigrationValidators::Core::DbValidator.clear_all
  end

  for_test_table do

    #integer
    for_integer_column  do
      with_validator :inclusion do
        with_option :as => :trigger do
          #closed integer interval
          with_options :in => 1..9 do
            it { should allow(1,4,9) }
            it { should deny(0, 10).with_initial(1) }
          end

          #open integer interval
          with_options :in => 1...9 do
            it { should allow(1,4) }
            it { should deny(0, 9, 10).with_initial(1) }
          end

          #single value
          with_options :in => 9 do
            it { should allow(9) }
            it { should deny(8, 10).with_initial(9) }
          end

          #array
          with_options :in => [1, 9] do
            it { should allow(1, 9) }
            it { should deny(0, 3, 10).with_initial(1) }
          end

          with_options :in => 9, :message => "Some error message" do
            it { should deny(8, 10).with_initial(9).and_message(/Some error message/) }

            with_option :on => :update do
              it { should allow.insert(8, 10) }
            end

            with_option :on => :create do
              it { should allow.update(8, 10).with_initial(9) }
            end
          end
        end

        with_option :as => :check do
          #closed integer interval
          with_options :in => 1..9 do
            it { should allow(1,4,9) }
            it { should deny(0, 10).with_initial(1) }
          end

          #open integer interval
          with_options :in => 1...9 do
            it { should allow(1,4) }
            it { should deny(0, 9, 10).with_initial(1) }
          end

          #single value
          with_options :in => 9 do
            it { should allow(9) }
            it { should deny(8, 10).with_initial(9) }
          end

          #array
          with_options :in => [1, 9] do
            it { should allow(1, 9) }
            it { should deny(0, 3, 10).with_initial(1) }
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do
          #closed integer interval
          with_options :in => 1..9 do
            it { should allow(0, 10) }
            it { should deny(1,4,9).with_initial(0) }
          end

          #open integer intervalw
          with_options :in => 1...9 do
            it { should allow(0, 9, 10) }
            it { should deny(1,4).with_initial(0) }
          end

          #single value
          with_options :in => 9 do
            it { should allow(8, 10) }
            it { should deny(9).with_initial(0) }
          end

          #array
          with_options :in => [1, 9] do
            it { should allow(0, 3, 10) }
            it { should deny(1, 9).with_initial(0) }
          end

          with_options :in => 9, :message => "Some error message" do
            it { should deny(9).with_initial(8).and_message(/Some error message/) }

            with_option :on => :update do
              it { should allow.insert(9) }
            end

            with_option :on => :create do
              it { should allow.update(9).with_initial(8) }
            end
          end
        end

        with_option :as => :check do
          #closed integer interval
          with_options :in => 1..9 do
            it { should allow(0, 10) }
            it { should deny(1,4,9).with_initial(0) }
          end

          #open integer intervalw
          with_options :in => 1...9 do
            it { should allow(0, 9, 10) }
            it { should deny(1,4).with_initial(0) }
          end

          #single value
          with_options :in => 9 do
            it { should allow(8, 10) }
            it { should deny(9).with_initial(0) }
          end

          #array
          with_options :in => [1, 9] do
            it { should allow(0, 3, 10) }
            it { should deny(1, 9).with_initial(0) }
          end
        end
      end

      with_validator :uniqueness do
        with_option :as => :trigger do
          it { should deny.insert.at_least_one(1,1)}
          it { should deny.update(1).with_initial(1,2)}
          it { should allow.insert(1,2,3) }

          with_option :message => "Some error message" do
            it { should deny.at_least_one(1,1).with_initial(1).and_message(/Some error message/) }
          end 
        end

        with_option :as => :index do
          it { should deny.insert.at_least_one(1,1).with_message(/duplicate key value violates unique constraint/) }
          it { should deny.update(1).with_initial(1,2).and_message(/duplicate key value violates unique constraint/) }
          it { should allow.insert(1,2,3) }
          it { should allow.update(1).with_initial(2) }
        end
      end
    end

    for_integer_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :inclusion => {:in => 1..9, :as => :trigger, :message => "Some error message"}} do
      it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
      it { should deny(10).with_initial(8).and_message(/Some error message/) }

      with_change :inclusion => false do
        it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
        it { should allow(10) }
      end

      with_change :inclusion => {:in => 1..9} do
        with_change :inclusion => false do
          it { should allow(10) }
        end
      end
    end

    for_integer_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :inclusion => {:in => 1..9, :as => :check}} do
      it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
      it { should deny(10).with_initial(8) }

      with_change :inclusion => false do
        it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
        it { should allow(10) }
      end

      with_change :inclusion => {:in => 1..9} do
        with_change :inclusion => false do
          it { should allow(10) }
        end
      end
    end

    for_integer_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :exclusion => {:in => 4..9, :as => :trigger, :message => "Some error message"}} do
      it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
      it { should deny(9).with_initial(10).and_message(/Some error message/) }

      with_change :exclusion => false do
        it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
        it { should allow(9) }
      end

      with_change :exclusion => {:in => 4..9} do
        with_change :exclusion => false do
          it { should allow(9) }
        end
      end
    end

    for_integer_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :exclusion => {:in => 4..9, :as => :check}} do
      it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
      it { should deny(9).with_initial(10) }

      with_change :exclusion => false do
        it { should deny.at_least_one(1,1).with_initial(1, 2).and_message(/duplicate key value violates unique constraint/) }
        it { should allow(9) }
      end

      with_change :exclusion => {:in => 4..9} do
        with_change :exclusion => false do
          it { should allow(9) }
        end
      end
    end

    #float
    for_float_column do
      with_validator :inclusion do
        with_option :as => :trigger do
          #closed integer interval
          with_options :in => 1.1..9.1 do
            it { should allow(1.1, 9.1) }
            it { should deny(1.0, 9.2).with_initial(1.1) }
          end

          #open integer interval
          with_options :in => 1.1...9.1 do
            it { should allow(1.1, 9) }
            it { should deny(1.0, 9.1, 9.2).with_initial(1.1) }
          end

          #single value
          with_options :in => 9.1 do
            it { should allow(9.1) }
            it { should deny(8.1, 10.1).with_initial(9.1) }
          end

          #array
          with_options :in => [1.1, 9.1] do
            it { should allow(1.1, 9.1) }
            it { should deny(0.1, 3.1, 10.1).with_initial(1.1) }
          end

          with_options :in => 9.1, :message => "Some error message" do
            it { should deny(8.1, 10.1).with_initial(9.1).and_message(/Some error message/) }
          end
        end

        with_option :as => :check do
          #closed integer interval
          with_options :in => 1.1..9.1 do
            it { should allow(1.1, 9.1) }
            it { should deny(1.0, 9.2).with_initial(1.1) }
          end

          #open integer interval
          with_options :in => 1.1...9.1 do
            it { should allow(1.1, 9) }
            it { should deny(1.0, 9.1, 9.2).with_initial(1.1) }
          end

          #single value
          with_options :in => 9.1 do
            it { should allow(9.1) }
            it { should deny(8.1, 10.1).with_initial(9.1) }
          end

          #array
          with_options :in => [1.1, 9.1] do
            it { should allow(1.1, 9.1) }
            it { should deny(0.1, 3.1, 10.1).with_initial(1.1) }
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do
          #closed integer interval
          with_options :in => 1.1..9.1 do
            it { should allow(1.0, 9.2) }
            it { should deny(1.1, 9.1).with_initial(1.0) }
          end

          #open integer interval
          with_options :in => 1.1...9.1 do
            it { should allow(1.0, 9.1, 9.2) }
            it { should deny(1.1, 9).with_initial(1.0) }
          end

          #single value
          with_options :in => 9.1 do
            it { should deny(9.1).with_initial(9.0) }
            it { should allow(8.1, 10.1) }
          end

          #array
          with_options :in => [1.1, 9.1] do
            it { should deny(1.1, 9.1).with_initial(1.0) }
            it { should allow(0.1, 3.1, 10.1) }
          end

          with_options :in => 9.1, :message => "Some error message" do
            it { should deny(9.1).with_initial(9.0).and_message(/Some error message/) }
          end
        end

        with_option :as => :check do
          #closed integer interval
          with_options :in => 1.1..9.1 do
            it { should allow(1.0, 9.2) }
            it { should deny(1.1, 9.1).with_initial(1.0) }
          end

          #open integer interval
          with_options :in => 1.1...9.1 do
            it { should allow(1.0, 9.1, 9.2) }
            it { should deny(1.1, 9).with_initial(1.0) }
          end

          #single value
          with_options :in => 9.1 do
            it { should deny(9.1).with_initial(9.0) }
            it { should allow(8.1, 10.1) }
          end

          #array
          with_options :in => [1.1, 9.1] do
            it { should deny(1.1, 9.1).with_initial(1.0) }
            it { should allow(0.1, 3.1, 10.1) }
          end
        end
      end
    end

    #string
    for_string_column do

      with_validator :format do
        with_option :as => :trigger do
          with_option :with => /^start/ do
            it { should allow('start stop') }
            it { should deny('stop start').with_initial('start') }
            it { should deny('stop').with_initial('start') }

            with_option :on => :update do
              it { should allow.insert('stop')}
            end

            with_option :on => :create do
              it { should allow.update('stop').with_initial('start')}
            end

            with_option :message => "Some error message" do
              it { should deny('stop').with_initial('start').and_message(/Some error message/) }
            end
          end
        end

        with_option :as => :check do
          with_option :with => /^start/ do
            it { should allow('start stop') }
            it { should deny('stop start').with_initial('start') }
            it { should deny('stop').with_initial('start') }
          end
        end
      end

      with_validator :presence do
        with_option :as => :trigger do
          it { should allow('b') }
          it { should deny(nil).with_initial('b') }

          with_option :allow_blank => true do
            it { should allow(nil) }
          end

          with_option :allow_nil => true do
            it { should allow(nil) }
          end

          with_option :on => :update do
            it { should allow.insert(nil) }
          end

          with_option :on => :create do
            it { should allow.update(nil).with_initial('b') }
          end
        end

        with_option :as => :check do
          it { should allow('b') }
          it { should deny(nil).with_initial('b') }

          with_option :allow_blank => true do
            it { should allow(nil) }
          end

          with_option :allow_nil => true do
            it { should allow(nil) }
          end
        end
      end

      with_validator :uniqueness do
        with_option :as => :trigger do
          it { should deny.at_least_one(' ', ' ').with_initial(' ', 'a') }

          with_option :allow_blank => true do
            it { should allow(' ', ' ') }
          end
        end
      end

      with_validator :inclusion do
        with_option :as => :trigger do
          #closed string interval
          with_options :in => 'b'..'e' do
            it { should allow('b', 'd', 'e') }
            it { should deny('a', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #open string interval
          with_options :in => 'b'...'e' do
            it { should allow('b', 'd') }
            it { should deny('a', 'e', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #single string value
          with_options :in => 'b' do
            it { should allow('b') }
            it { should deny('a', 'c').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #array
          with_options :in => ['b', 'e'] do
            it { should allow('b', 'e') }
            it { should deny('a', 'c', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          with_options :in => 'b'  do
            it { should allow('b') }

            with_option :message => "Some error message" do
              it { should deny('c').with_initial('b').with_message(/Some error message/) }
            end

            it { should deny(' ').with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end
          end
        end

        with_option :as => :check do
          #closed string interval
          with_options :in => 'b'..'e' do
            it { should allow('b', 'd', 'e') }
            it { should deny('a', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #open string interval
          with_options :in => 'b'...'e' do
            it { should allow('b', 'd') }
            it { should deny('a', 'e', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #single string value
          with_options :in => 'b' do
            it { should allow('b') }
            it { should deny('a', 'c').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          #array
          with_options :in => ['b', 'e'] do
            it { should allow('b', 'e') }
            it { should deny('a', 'c', 'f').with_initial('b') }
            it { should deny(' ').with_initial('b') }
            it { should deny(nil).with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end

            with_option :allow_nil => true do
              it { should allow(nil) }
            end
          end

          with_options :in => 'b'  do
            it { should allow('b') }
            it { should deny(' ').with_initial('b') }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do
          #closed string interval
          with_options :in => 'b'..'e' do
            it { should allow('a', 'f') }
            it { should deny('b', 'd', 'e').with_initial('a') }
            it { should allow(nil) }
          end

          #open string interval
          with_options :in => 'b'...'e' do
            it { should deny('b', 'd').with_initial('a') }
            it { should allow('a', 'e', 'f') }
            it { should allow(nil) }
          end

          #single string value
          with_options :in => 'b' do
            it { should deny('b').with_initial('a') }
            it { should allow('a', 'c') }
            it { should allow(nil) }
          end

          #array
          with_options :in => ['b', 'e', ' '] do
            it { should deny('b', 'e').with_initial('a') }
            it { should allow('a', 'c', 'f') }
            it { should deny(' ').with_initial('a') }
            it { should allow(nil) }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end
          end

          with_options :in => 'b', :message => "Some error message" do
            it { should deny('b').with_initial('a').with_message(/Some error message/) }
          end
        end

        with_option :as => :check do
          #closed string interval
          with_options :in => 'b'..'e' do
            it { should allow('a', 'f') }
            it { should deny('b', 'd', 'e').with_initial('a') }
            it { should allow(nil) }
          end

          #open string interval
          with_options :in => 'b'...'e' do
            it { should deny('b', 'd').with_initial('a') }
            it { should allow('a', 'e', 'f') }
            it { should allow(nil) }
          end

          #single string value
          with_options :in => 'b' do
            it { should deny('b').with_initial('a') }
            it { should allow('a', 'c') }
            it { should allow(nil) }
          end

          #array
          with_options :in => ['b', 'e', ' '] do
            it { should deny('b', 'e').with_initial('a') }
            it { should allow('a', 'c', 'f') }
            it { should deny(' ').with_initial('a') }
            it { should allow(nil) }

            with_option :allow_blank => true do
              it { should allow(' ') }
            end
          end
        end
      end

      with_validator :length do
        with_option :as => :trigger do
          with_option :is => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }

            with_option :message => "Some error message" do
              it {should deny('123456').with_initial('12345').with_message("Some error message") }
              
              with_option :wrong_length => "Some specific error message" do
                it {should deny('123456').with_initial('12345').with_message("Some specific error message") }
              end
            end

            with_option :on => :create do
              it {should deny.insert('1234', '123456') }
              it {should allow.update('1234', '123456').with_initial('12345') }
            end

            with_option :on => :update do
              it {should allow.insert('1234', '123456') }
              it {should deny.update('1234', '123456').with_initial('12345') }
            end

            it {should deny(' ', nil).with_initial('12345') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :is => 0 do
            it { should allow(nil) }
          end


          with_option :maximum => 5 do
            it {should allow('1234', '12345') }
            it {should deny('123456').with_initial('12345') }

            with_option :message => "Some error message" do
              it {should deny('123456').with_initial('12345').with_message("Some error message") }
              
              with_option :too_long => "Some specific error message" do
                it {should deny('123456').with_initial('12345').with_message("Some specific error message") }
              end
            end

            it { should allow(' ', nil) }
          end

          with_option :minimum => 5 do
            it {should allow('12345', '123456') }
            it {should deny('1234').with_initial('12345') }

            with_option :message => "Some error message" do
              it {should deny('1234').with_initial('12345').with_message("Some error message") }
              
              with_option :too_short => "Some specific error message" do
                it {should deny('1234').with_initial('12345').with_message("Some specific error message") }
              end
            end

            it {should deny(' ', nil).with_initial('12345') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :minimum => 0 do
            it { should allow(' ', nil) }
          end

          with_option :in => 2..5 do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => 0..1 do
            it { should allow(' ', nil) }
          end

          with_option :in => 2...5 do
            it {should allow('12', '123') }
            it {should deny('1', '12345', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => 0...2 do
            it { should allow(' ', nil) }
          end

          with_option :in => [2, 3, 5] do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '1234', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => [0, 1] do
            it { should allow(' ', nil) }
          end

          with_option :in => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }
          end

          with_option :within => 2..5 do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => 0..1 do
            it { should allow(' ', nil) }
          end

          with_option :within => 2...5 do
            it {should allow('12', '123') }
            it {should deny('1', '12345', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => 0...2 do
            it { should allow(' ', nil) }
          end

          with_option :within => [2, 3, 5] do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '1234', '123456').with_initial('12') }

            with_option :message => "Some error message" do
              it {should deny('1').with_initial('12').with_message("Some error message") }
            end

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => [0, 1] do
            it { should allow(' ', nil) }
          end

          with_option :within => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }
          end
        end

        with_option :as => :check do
          with_option :is => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }

            it {should deny(' ', nil).with_initial('12345') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :is => 0 do
            it { should allow(nil) }
          end


          with_option :maximum => 5 do
            it {should allow('1234', '12345') }
            it {should deny('123456').with_initial('12345') }
            it { should allow(' ', nil) }
          end

          with_option :minimum => 5 do
            it {should allow('12345', '123456') }
            it {should deny('1234').with_initial('12345') }

            it {should deny(' ', nil).with_initial('12345') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :minimum => 0 do
            it { should allow(' ', nil) }
          end

          with_option :in => 2..5 do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => 0..1 do
            it { should allow(' ', nil) }
          end

          with_option :in => 2...5 do
            it {should allow('12', '123') }
            it {should deny('1', '12345', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => 0...2 do
            it { should allow(' ', nil) }
          end

          with_option :in => [2, 3, 5] do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '1234', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :in => [0, 1] do
            it { should allow(' ', nil) }
          end

          with_option :in => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }
          end

          with_option :within => 2..5 do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => 0..1 do
            it { should allow(' ', nil) }
          end

          with_option :within => 2...5 do
            it {should allow('12', '123') }
            it {should deny('1', '12345', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => 0...2 do
            it { should allow(' ', nil) }
          end

          with_option :within => [2, 3, 5] do
            it {should allow('12', '123', '12345') }
            it {should deny('1', '1234', '123456').with_initial('12') }

            it {should deny(' ', nil).with_initial('12') }
         
            with_option :allow_blank => true do
              it { should allow.insert(' ') }
            end

            with_option :allow_nil => true do
              it { should allow.insert(nil) }
            end
          end

          with_option :within => [0, 1] do
            it { should allow(' ', nil) }
          end

          with_option :within => 5 do
            it {should allow('12345') }
            it {should deny('1234', '123456').with_initial('12345') }
          end
        end
      end
    end

    for_string_column :validates => {:uniqueness => {:as => :index}, :length => {:in => 4..9, :as => :trigger, :message => "Some error message"}} do
      it { should deny.at_least_one('1234','1234').with_initial('1234', '12345').and_message(/duplicate key value violates unique constraint/) }
      it { should deny('123').with_initial('1234').and_message(/Some error message/) }

      with_change :length => false do
        it { should deny.at_least_one('1234','1234').with_initial('1234', '12345').and_message(/duplicate key value violates unique constraint/) }
        it { should allow('123') }
      end

      with_change :length => {:in => 4..9} do
        with_change :length => false do
          it { should allow('123') }
        end
      end
    end

    for_string_column :validates => {:uniqueness => {:as => :index}, :length => {:in => 4..9, :as => :check}} do
      it { should deny.at_least_one('1234','1234').with_initial('1234', '12345').and_message(/duplicate key value violates unique constraint/) }
      it { should deny('123').with_initial('1234') }

      with_change :length => false do
        it { should deny.at_least_one('1234','1234').with_initial('1234', '12345').and_message(/duplicate key value violates unique constraint/) }
        it { should allow('123') }
      end

      with_change :length => {:in => 4..9} do
        with_change :length => false do
          it { should allow('123') }
        end
      end
    end

    for_string_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :format => {:with => /^start/, :as => :trigger, :message => "Some error message"}} do
      it { should deny.at_least_one('start','start').with_initial('start', 'start1').and_message(/duplicate key value violates unique constraint/) }
      it { should deny('stop').with_initial('start').and_message(/Some error message/) }

      with_change :format => false do
        it { should deny.at_least_one('start','start').with_initial('start', 'start1').and_message(/duplicate key value violates unique constraint/) }
        it { should allow('stop') }
      end

      with_change :format => {:with => /^start/} do
        with_change :format => false do
          it { should allow('stop') }
        end
      end
    end

    for_string_column :validates => {:uniqueness => {:as => :index, :message => "Some error message"}, :format => {:with => /^start/, :as => :check}} do
      it { should deny.at_least_one('start','start').with_initial('start', 'start1').and_message(/duplicate key value violates unique constraint/) }
      it { should deny('stop').with_initial('start')}

      with_change :format => false do
        it { should deny.at_least_one('start','start').with_initial('start', 'start1').and_message(/duplicate key value violates unique constraint/) }
        it { should allow('stop') }
      end

      with_change :format => {:with => /^start/} do
        with_change :format => false do
          it { should allow('stop') }
        end
      end
    end

    #date
    for_date_column do
      startDate = Date.today - 5
      endDate = Date.today

      with_validator :inclusion do
        with_option :as => :trigger do

          #closed date interval
          with_options :in => startDate..endDate do
            it { should allow(startDate, endDate - 3, endDate) }
            it { should deny(startDate - 1, endDate + 1).with_initial(endDate - 1) }
          end

          #open date interval
          with_options :in => startDate...endDate do
            it { should allow(startDate, endDate - 3) }
            it { should deny(startDate - 1, endDate, endDate + 1).with_initial(endDate - 1) }
          end

          #single date value
          with_options :in => endDate do
            it { should allow(endDate) }
            it { should deny(endDate - 1, endDate + 1).with_initial(endDate) }
          end

          #array
          with_options :in => [startDate, endDate] do
            it { should allow(startDate, endDate) }
            it { should deny(startDate - 1, endDate - 1, endDate + 1).with_initial(endDate) }
          end

          with_options :in => endDate, :message => "Some error message" do
            it { should deny(endDate + 1).with_initial(endDate).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed date interval
          with_options :in => startDate..endDate do
            it { should allow(startDate, endDate - 3, endDate) }
            it { should deny(startDate - 1, endDate + 1).with_initial(endDate - 1) }
          end

          #open date interval
          with_options :in => startDate...endDate do
            it { should allow(startDate, endDate - 3) }
            it { should deny(startDate - 1, endDate, endDate + 1).with_initial(endDate - 1) }
          end

          #single date value
          with_options :in => endDate do
            it { should allow(endDate) }
            it { should deny(endDate - 1, endDate + 1).with_initial(endDate) }
          end

          #array
          with_options :in => [startDate, endDate] do
            it { should allow(startDate, endDate) }
            it { should deny(startDate - 1, endDate - 1, endDate + 1).with_initial(endDate) }
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do

          #closed date interval
          with_options :in => startDate..endDate do
            it { should deny(startDate, endDate - 3, endDate).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate + 1) }
          end

          #open date interval
          with_options :in => startDate...endDate do
            it { should deny(startDate, endDate - 3).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate, endDate + 1) }
          end

          #single date value
          with_options :in => endDate do
            it { should deny(endDate).with_initial(endDate - 1) }
            it { should allow(endDate - 1, endDate + 1) }
          end

          #array
          with_options :in => [startDate, endDate] do
            it { should deny(startDate, endDate).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate - 1, endDate + 1) }
          end

          with_options :in => endDate, :message => "Some error message" do
            it { should deny(endDate).with_initial(endDate - 1).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed date interval
          with_options :in => startDate..endDate do
            it { should deny(startDate, endDate - 3, endDate).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate + 1) }
          end

          #open date interval
          with_options :in => startDate...endDate do
            it { should deny(startDate, endDate - 3).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate, endDate + 1) }
          end

          #single date value
          with_options :in => endDate do
            it { should deny(endDate).with_initial(endDate - 1) }
            it { should allow(endDate - 1, endDate + 1) }
          end

          #array
          with_options :in => [startDate, endDate] do
            it { should deny(startDate, endDate).with_initial(startDate - 1) }
            it { should allow(startDate - 1, endDate - 1, endDate + 1) }
          end
        end
      end
    end

    #time
    for_time_column do
      startTime = Time.now - 10
      endTime = Time.now

      with_validator :inclusion do
        with_option :as => :trigger do

          #closed time interval
          with_options :in => startTime..endTime do
            it { should allow(startTime, startTime + 1, endTime) }
            it { should deny(startTime - 1, endTime + 1).with_initial(startTime) }
          end

          #open time interval
          with_options :in => startTime...endTime do
            it { should allow(startTime, startTime + 1, endTime - 1) }
            it { should deny(startTime - 1, endTime).with_initial(startTime) }
          end

          #single time value
          with_options :in => startTime do
            it { should allow(startTime) }
            it { should deny(startTime - 1, endTime).with_initial(startTime) }
          end

          #array
          with_options :in => [startTime, endTime] do
            it { should allow(startTime, endTime) }
            it { should deny(startTime - 1, startTime + 1, endTime + 1).with_initial(startTime) }
          end

          with_options :in => startTime, :message => "Some error message" do
            it { should deny(startTime + 1).with_initial(startTime).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed time interval
          with_options :in => startTime..endTime do
            it { should allow(startTime, startTime + 1, endTime) }
            it { should deny(startTime - 1, endTime + 1).with_initial(startTime) }
          end

          #open time interval
          with_options :in => startTime...endTime do
            it { should allow(startTime, startTime + 1, endTime - 1) }
            it { should deny(startTime - 1, endTime).with_initial(startTime) }
          end

          #single time value
          with_options :in => startTime do
            it { should allow(startTime) }
            it { should deny(startTime - 1, endTime).with_initial(startTime) }
          end

          #array
          with_options :in => [startTime, endTime] do
            it { should allow(startTime, endTime) }
            it { should deny(startTime - 1, startTime + 1, endTime + 1).with_initial(startTime) }
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do

          #closed time interval
          with_options :in => startTime..endTime do
            it { should deny(startTime, startTime + 1, endTime).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime + 1) }
          end

          #open time interval
          with_options :in => startTime...endTime do
            it { should deny(startTime, startTime + 1, endTime - 1).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime) }
          end

          #single time value
          with_options :in => startTime do
            it { should deny(startTime).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime) }
          end

          #array
          with_options :in => [startTime, endTime] do
            it { should deny(startTime, endTime).with_initial(startTime - 1)  }
            it { should allow(startTime - 1, startTime + 1, endTime + 1)}
          end

          with_options :in => startTime, :message => "Some error message" do
            it { should deny(startTime).with_initial(startTime - 1).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed time interval
          with_options :in => startTime..endTime do
            it { should deny(startTime, startTime + 1, endTime).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime + 1) }
          end

          #open time interval
          with_options :in => startTime...endTime do
            it { should deny(startTime, startTime + 1, endTime - 1).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime) }
          end

          #single time value
          with_options :in => startTime do
            it { should deny(startTime).with_initial(startTime - 1) }
            it { should allow(startTime - 1, endTime) }
          end

          #array
          with_options :in => [startTime, endTime] do
            it { should deny(startTime, endTime).with_initial(startTime - 1)  }
            it { should allow(startTime - 1, startTime + 1, endTime + 1)}
          end
        end
      end
    end

    #datetime
    for_datetime_column do
      startDateTime = DateTime.now - 10
      endDateTime = DateTime.now

      with_validator :inclusion do
        with_option :as => :trigger do

          #closed time interval
          with_options :in => startDateTime..endDateTime do
            it { should allow(startDateTime, startDateTime + 1, endDateTime) }
            it { should deny(startDateTime - 1, endDateTime + 1).with_initial(startDateTime) }
          end

          #open time interval
          with_options :in => startDateTime...endDateTime do
            it { should allow(startDateTime, startDateTime + 1, endDateTime - 1) }
            it { should deny(startDateTime - 1, endDateTime).with_initial(startDateTime) }
          end

          #single time value
          with_options :in => startDateTime do
            it { should allow(startDateTime) }
            it { should deny(startDateTime - 1, endDateTime).with_initial(startDateTime) }
          end

          #array
          with_options :in => [startDateTime, endDateTime] do
            it { should allow(startDateTime, endDateTime) }
            it { should deny(startDateTime - 1, startDateTime + 1, endDateTime + 1).with_initial(startDateTime) }
          end

          with_options :in => startDateTime, :message => "Some error message" do
            it { should deny(startDateTime + 1).with_initial(startDateTime).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed time interval
          with_options :in => startDateTime..endDateTime do
            it { should allow(startDateTime, startDateTime + 1, endDateTime) }
            it { should deny(startDateTime - 1, endDateTime + 1).with_initial(startDateTime) }
          end

          #open time interval
          with_options :in => startDateTime...endDateTime do
            it { should allow(startDateTime, startDateTime + 1, endDateTime - 1) }
            it { should deny(startDateTime - 1, endDateTime).with_initial(startDateTime) }
          end

          #single time value
          with_options :in => startDateTime do
            it { should allow(startDateTime) }
            it { should deny(startDateTime - 1, endDateTime).with_initial(startDateTime) }
          end

          #array
          with_options :in => [startDateTime, endDateTime] do
            it { should allow(startDateTime, endDateTime) }
            it { should deny(startDateTime - 1, startDateTime + 1, endDateTime + 1).with_initial(startDateTime) }
          end
        end
      end

      with_validator :exclusion do
        with_option :as => :trigger do

          #closed time interval
          with_options :in => startDateTime..endDateTime do
            it { should deny(startDateTime, startDateTime + 1, endDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime + 1) }
          end

          #open time interval
          with_options :in => startDateTime...endDateTime do
            it { should deny(startDateTime, startDateTime + 1, endDateTime - 1).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime) }
          end

          #single time value
          with_options :in => startDateTime do
            it { should deny(startDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime) }
          end

          #array
          with_options :in => [startDateTime, endDateTime] do
            it { should deny(startDateTime, endDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, startDateTime + 1, endDateTime + 1) }
          end

          with_options :in => startDateTime, :message => "Some error message" do
            it { should deny(startDateTime).with_initial(startDateTime - 1).with_message(/Some error message/) }
          end
        end

        with_option :as => :check do

          #closed time interval
          with_options :in => startDateTime..endDateTime do
            it { should deny(startDateTime, startDateTime + 1, endDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime + 1) }
          end

          #open time interval
          with_options :in => startDateTime...endDateTime do
            it { should deny(startDateTime, startDateTime + 1, endDateTime - 1).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime) }
          end

          #single time value
          with_options :in => startDateTime do
            it { should deny(startDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, endDateTime) }
          end

          #array
          with_options :in => [startDateTime, endDateTime] do
            it { should deny(startDateTime, endDateTime).with_initial(startDateTime - 1) }
            it { should allow(startDateTime - 1, startDateTime + 1, endDateTime + 1) }
          end
        end
      end
    end
  end
end
