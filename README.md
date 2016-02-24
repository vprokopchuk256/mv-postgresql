[![Build Status](https://travis-ci.org/vprokopchuk256/mv-postgresql.svg?branch=master)](https://travis-ci.org/vprokopchuk256/mv-postgresql)
[![Coverage Status](https://coveralls.io/repos/vprokopchuk256/mv-postgresql/badge.png?branch=master)](https://coveralls.io/r/vprokopchuk256/mv-postgresql?branch=master)
[![Gem Version](https://badge.fury.io/rb/mv-postgresql.svg)](http://badge.fury.io/rb/mv-postgresql)

# `Migration Validators` project. PostgreSQL driver.

Define validations directly in DB as PostgreSQL constraints and integrate them into your model transparently. See [mv-core](https://github.com/vprokopchuk256/mv-core) for details. There you will be able to review high level project information. Below you can see details of the migration validations that are supported by PostgreSQL driver.

#Table Of Contents
* [Validations](#validations)
  * [uniqueness](#uniqueness)
  * [length](#length)
  * [inclusion](#inclusion)
  * [exclusion](#exclusion)
  * [presence](#presence)
  * [absence](#absence)
  * [format](#format)
  * [custom](#custom)
* [Version History](#version history)
* [Contributing](#contributing)

# Validations

### uniqueness

  Examples:

  validate uniqueness of the column `column_name`:

  ```ruby
  def up
    validates :table_name, :column_name, uniqueness: true
  end

  def down
    validates :table_name, :column_name, uniqueness: false
  end
  ```

  define validation as trigger with specified failure message:

  ```ruby
  def up
    validates :table_name, :column_name,
                    uniqueness: { message: 'Error message', as: :trigger }
  end

  def down
    validates :table_name, :column_name, uniqueness: false
  end
  ```

  define validation as unique index:

  ```ruby
  def up
    validates :table_name, :column_name, uniqueness: { as: :index }
  end

  def down
    validates :table_name, :column_name, uniqueness: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.string :column_name, validates: { uniqueness: true }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :string, validates: { uniqueness: false }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :string, validates: { uniqueness: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
       t.string :column_name, uniqueness: true
    end
  end
  ```

  Options:

  * `:message` - text of the error message that will be shown if constraint violated.  Ignored unless `:as == :trigger`
  * `:index_name` - name of the index that will be created for validator. Ignored unless `:as == :index`
  * `:on` - validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value `:save`
  * `:create_tigger_name` - name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `:update_tigger_name` - name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `:allow_nil` - ignore validation for nil values. Ignored unless `:as == :trigger`. Default value: `false`
  * `:allow_blank` - ignore validation for blank values. Ignored unless `:as == :trigger`. Default value: `false`
  * `:as` - defines the way how constraint will be implemented. Possible values: `[:index, :trigger]`. Default value: `:index`

### length

Examples:

  ```ruby
  def up
    validates :table_name, :column_name,
              length: { in: 5..8, message: 'Wrong length message'}
  end

  def down
    validates :table_name, :column_name, length: false
  end
  ```

allow `NULL`:

  ```ruby
  def up
    validates :table_name, :column_name,
              length: { is: 3, allow_nil: true}
  end

  def down
    validates :table_name, :column_name, length: false
  end
  ```

  allow blank values:

  ```ruby
  def up
    validates :table_name, :column_name,
              length: { maximum: 3,
                        allow_blank: true,
                        too_long: 'Value is longer than 3 symbols' }
  end

  def down
    validates :table_name, :column_name, length: false
  end
  ```

  define constraint in trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
                         length: { maximum: 3,
                                   as: :trigger,
                                   too_long: 'Value is longer than 3 symbols' }
  end

  def down
    validates :table_name, :column_name, length: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.string :column_name, validates: { length: { is: 3, allow_nil: true} }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :string, validates: { length: { is: 3 } }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :string, validates: { length: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :string_3, length: 3
      t.string :string_from_1_to_3, length: 1..3,
      t.string :string_1_or_3, length: [1, 3]
      t.string :string_4, validates: { length: 4 }
      t.string :string_4_in_trigger: length: { is: 4, as: :trigger }
    end
  end
  ```

  Options:

  * `in` - range or array that length of the value should be contained in.
  * `within` - synonym of `:in`
  * `is` - exact length of the value
  * `maximum` -  maximum allowed length
  * `minimum` - minimum allowed length
  * `message` - message that should be shown if validation failed and specific message is not defined
  * `too_long` - message that will be shown if value longer than allowed. Ignored unless maximum value is defined
  * `too_short` - message that will be shown if value shorter than allowed. Ignored unless minimum value is defined
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for nil values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

### inclusion

  Examples:

  valid values array:

  ```ruby
  def up
    validates :table_name, :column_name, inclusion: { in: [1, 2, 3] }
  end

  def down
    validates :table_name, :column_name, inclusion: false
  end
  ```

  with failure message specified:

  ```ruby
  def up
    validates :table_name, :column_name,
    inclusion: { in: [1, 2, 3],
                 message: "Column value should be equal to 1 or 2 or 3" }
  end

  def down
    validates :table_name, :column_name, inclusion: false
  end
  ```

  make it as check constraint:

  ```ruby
  def up
    validates :table_name, :column_name,
              inclusion: { in: [1, 2, 3], as: :check }
  end

  def down
    validates :table_name, :column_name, inclusion: false
  end
  ```

  make it in trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
                           inclusion: { in: 1..3,
                                        on: :create,
                                        as: :trigger }
  end

  def down
    validates :table_name, :column_name, inclusion: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.integer :column_name, validates: { inclusion: { in: 1..3 } }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :integer, validates: { inclusion: { in: 1..3 } }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :integer, validates: { inclusion: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :str_or_str_1, inclusion: ['str', 'str1']
      t.string :from_str_to_str_1, inclusion: 'str'..'str1'
      t.string :str_or_str_1_in_trigger, inclusion: { in: ['str', 'str1'],
                                                      as: :trigger}
    end
  end
  ```

  Options:

  * `in` - range or array that column value should be contained in.
  * `message` - message that should be shown if validation failed
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for nil values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`


### exclusion

  Examples:

  exclude 1, 2, and 3:

  within `create_table` statement:

  ```ruby
  def change
    create_table :tabld_name do |t|
      t.integer :column_name, validates: { exclusion: { in: [1, 2, 3] } }
    end
  end
  ```

  or as standalone statements:

  ```ruby
  def up
    validates :table_name, :column_name, exclusion: { in: [1, 2, 3] }
  end

  def down
    validates :table_name, :column_name, exclusion: false
  end
  ```

  the same with failure message:

  ```ruby
  def up
    validates :table_name, :column_name,
      exclusion: {
        in: [1, 2, 3],
        message: "Column 'column_name' should not  be equal to 1 or 2 or 3" }
  end

  def down
    validates :table_name, :column_name, exclusion: false
  end
  ```

  as check constraint:

  ```ruby
  def up
  validates :table_name, :column_name,
                         exclusion: { in: [1, 2, 3], as: :check }
  end

  def down
    validates :table_name, :column_name, exclusion: false
  end
  ```

  as trigger:

  ```ruby
  def up
  validates :table_name, :column_name,
                               exclusion: { in: 1..3,
                                            on: :create,
                                            as: :trigger }
  end

  def down
    validates :table_name, :column_name, exclusion: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.integer :column_name, validates: { exclusion: { in: 1..3 } }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :integer, validates: { exclusion: { in: 1..3 } }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :integer, validates: { exclusion: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :neither_str_nor_str_1, exclusion: ['str', 'str1']
      t.string :from_str_to_str_1, exclusion: 'str'..'str1'
      t.string :str_or_str_1_in_trigger, exclusion: { in: ['str', 'str1'],
                                                      as: :trigger}
    end
  end
  ```

  Options:

  * `:in` - range or array that column value should NOT be contained in.
  * `:message` - message that should be shown if validation failed
  * `:on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `:create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `:update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `:allow_nil` - ignore validation for `nil` values. Default value: `false`
  * `:allow_blank` - ignore validation for blank values. Default value: `false`
  * `:as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

### presence

  Examples:

  ```ruby
  def up
    validates :table_name, :column_name, presence: true
  end

  def down
    validates :table_name, :column_name, presence: false
  end
  ```

  with failure message:

  ```ruby
  def up
    validates :table_name, :column_name,
                    presence: { message: 'value should not be empty' }
  end

  def down
    validates :table_name, :column_name, presence: false
  end
  ```

  implemented as trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
                    presence: { message: 'value should not be empty',
                                as: :trigger }
  end

  def down
    validates :table_name, :column_name, presence: false
  end
  ```

  check when record is inserted only:

  ```ruby
  def up
    validates :table_name, :column_name,
                    presence: { message: 'value should not be empty',
                                as: :trigger,
                                on: :create }
  end

  def down
    validates :table_name, :column_name, presence: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.string :column_name, validates: { presence: true }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :string, validates: { presence: true }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :string, validates: { presence: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  create_table :table_name do |t|
    t.string :presence_in_check, presence: true
    t.string :presence_in_trigger, presence: { as: :trigger, on: :create }
  end
  ```

  Options:

  * `message` - message that should be shown if validation failed
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for `nil` values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

### absence

  Examples:

  ```ruby
  def up
    validates :table_name, :column_name, absence: true
  end

  def down
    validates :table_name, :column_name, absence: false
  end
  ```

  with failure message:

  ```ruby
  def up
    validates :table_name, :column_name,
                    absence: { message: 'value should be empty' }
  end

  def down
    validates :table_name, :column_name, absence: false
  end
  ```

  implemented as trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
                    absence: { message: 'value should be empty',
                                as: :trigger }
  end

  def down
    validates :table_name, :column_name, absence: false
  end
  ```

  check when record is inserted only:

  ```ruby
  def up
    validates :table_name, :column_name,
                    absence: { message: 'value should be empty',
                                as: :trigger,
                                on: :create }
  end

  def down
    validates :table_name, :column_name, absence: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
       t.string :column_name, validates: { absence: true }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
       t.change :column_name, :string, validates: { absence: true }
    end
  end

  def down
    change :table_name do |t|
       t.change :column_name, :string, validates: { absence: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :absence_in_check, absence: true
      t.string :absence_in_trigger, absence: { as: :trigger, on: :create }
    end
  end
  ```

  Options:

  * `message` - message that should be shown if validation failed
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for `nil` values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

### format

  Examples:

  allows only values that contains 'word' inside:

  ```ruby
  def up
    validates :table_name, :column_name, format: { with: /word/ }
  end

  def down
    validates :table_name, :column_name, format: false
  end
  ```

  with failure message:

  ```ruby
  def up
  validates :table_name, :column_name,
    format: { with: /word/,
              message: 'Column_name value should contain start word' }
  end

  def down
    validates :table_name, :column_name, format: false
  end
  ```

  implemented as trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
      format: { with: /word/,
                message: 'Column_name value should contain start word',
                as: :trigger }
  end

  def down
    validates :table_name, :column_name, format: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :column_name, validates { format: { with: /word/ } }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
      t.change :column_name, :string, validates: { format: { with: /word/ } }
    end
  end

  def down
    change :table_name do |t|
      t.change :column_name, :string, validates: { format: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :contains_word, format: /word/
      t.string :contains_word_in_trigger, format: { with: /word/,
                                                    as: :trigger }
    end
  end
  ```

  Options:

  * `with` - regular expression that column value should be matched to
  * `message` - message that should be shown if validation failed
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for `nil` values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

### custom

  (version >= 2.1 is required)

  Examples:

  allows only values that contains 'word' inside:

  ```ruby
  def up
    validates :table_name, :column_name,
                        custom: { statement: "TRIM({column_name}) ~ 'word'" }
  end

  def down
    validates :table_name, :column_name, custom: false
  end
  ```

  with failure message:

  ```ruby
  def up
    validates :table_name, :column_name,
      custom: { statement: "TRIM({column_name}) ~ 'word'",
                message: 'Column_name value should contain start word' }
  end

  def down
    validates :table_name, :column_name, custom: false
  end
  ```

  implemented as trigger:

  ```ruby
  def up
    validates :table_name, :column_name,
      custom: { statement: "TRIM({column_name}) ~ 'word'",
                message: 'Column_name value should contain start word',
                as: :trigger }
  end

  def down
    validates :table_name, :column_name, custom: false
  end
  ```

  all above are available in a create and change table blocks:

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :column_name,
            validates: { custom: { statement: "TRIM({column_name}) ~ 'word'"} }
    end
  end
  ```

  ```ruby
  def up
    change :table_name do |t|
      t.change :column_name, :string,
            validates: { custom: { statement: "TRIM({column_name}) ~ 'word'"} }
    end
  end

  def down
    change :table_name do |t|
      t.change :column_name, :string, validates: { custom: false }
    end
  end
  ```

  simplifications (version >= 2.1 is required):

  ```ruby
  def change
    create_table :table_name do |t|
      t.string :contains_word, custom: "TRIM({contains_word}) ~ 'word'"
      t.string :contains_word_synonym,
               validates: "TRIM({contains_word_synonym}) ~ 'word'"
      t.string :contains_word_in_trigger,
            custom: { statement: "TRIM({contains_word_in_trigger}) ~ 'word'",
            as: :trigger }
    end
  end
  ```

  Options:

  * `statement` - db expression that column value should be matched to
  * `message` - message that should be shown if validation failed
  * `on` -  validation event. Possible values `[:save, :update, :create]`. Ignored unless `:as == :trigger`. Default value: `:save`
  * `create_tigger_name` - Name of the 'before insert' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :create]`
  * `update_tigger_name` - Name of the 'before update' trigger that will be created if `:as == :trigger` && `:on` in `[:save, :update]`
  * `allow_nil` - ignore validation for `nil` values. Default value: `false`
  * `allow_blank` - ignore validation for blank values. Default value: `false`
  * `as` - defines the way how constraint will be implemented. Possible values: `[:trigger, :check]` Default value: `:check`

## Version History

**(2.0.0)** (17 Jan, 2015)

* Completely rewritten. Migrated to Ruby 2.0 and RoR 4

**(2.1.0)** (22 Jan, 2015)

* Custom validation

**(2.2.0)** (28 Jan, 2015)

* Integration with ActiveRecord

**(2.2.1)** (29 May, 2015)

* Made it possible to use several mv-* drivers in the same project

**(2.2.2)** (20 Jul, 2015)

* Fix issue with invalid parameters number in `add_column` and `change_column` methods

**(2.2.3)** (23 Nov, 2015)

* Do not camel case column name in error message

**(2.2.4)** (9 Feb, 2016)

* Support booleans in inclusion validator

**(2.2.5)** (23 Feb, 2016)

* Suppress exception while running db:schema:load

## Contributing

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

