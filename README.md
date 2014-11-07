# Introduction

mv-postgresql is the PostgreSQL driver for Migration Validators project (details here: https://github.com/vprokopchuk256/mv-core)

# Validators

### uniqueness

  Examples: 

  validate uniqueness of the column 'column_name':
  
  ```ruby
  validate_column :table_name, :column_name, uniqueness: true
  ```

  define validation as trigger with specified failure message:  

  ```ruby
  validate_column :table_name, :column_name, 
                  uniqueness: { message: 'Error message', as: :trigger }
  ```

  define validation as unique index: 

  ```ruby
  validate_column :table_name, :column_name, uniqueness: { as: :index }
  ```

  all above are available in a create and change table blocks: 

  ```ruby
  create_table :table_name do |t|
     t.string :column_name, validates: { uniqueness: true }
  end
  ```

  ```ruby
  change :table_name do |t|
     t.change :column_name, :string, :validates: { uniqueness: false }
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
  validate_column :table_name, :column_name, 
                               length: { in: 5..8, 
                                         message: 'Wrong length message'}
  ```

 allow `NULL`:

  ```ruby
  validate_column :table_name, :column_name, 
                               length: { is: 3, allow_nil: true}
  ```

  allow blank values: 

  ```ruby
  validate_column :table_name, :column_name, 
                        length: { maximum: 3, 
                                  too_long: 'Value is longer than 3 symbols' } 
  ```

  define constraint in trigger: 

  ```ruby
  validate_column :table_name, :column_name, 
                        length: { maximum: 3, 
                                  as: :trigger, 
                                  too_long: 'Value is longer than 3 symbols' } 
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
  validate_column :table_name, :column_name, inclusion: { in: [1, 2, 3] }
  ```

  with failure message specified: 

  ```ruby
  validate_column :table_name, :column_name, 
  inclusion: { in: [1, 2, 3], 
               message: "Column 'column_name' should be equal to 1 or 2 or 3" }
  ```

  make it as check constraint:

  ```ruby
  validate_column :table_name, :column_name, 
                               inclusion: { in: [1, 2, 3], 
                                            on: :update, 
                                            as: :check }
  ```

  make it in trigger: 

  ```ruby
  validate_column :table_name, :column_name, 
                               inclusion: { in: 1..3, 
                                            on: :create, 
                                            as: :trigger }
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

  ```ruby
  validate_column :table_name, :column_name, exclusion: { in: [1, 2, 3] }
  ```

  the same with failure message: 

  ```ruby
  validate_column :table_name, :column_name, 
    exclusion: {
      in: [1, 2, 3], 
      message: "Column 'column_name' should not  be equal to 1 or 2 or 3" }
  ```

  as check constraint: 

  ```ruby
  validate_column :table_name, :column_name, 
                               exclusion: { in: [1, 2, 3], 
                                            on: :update, 
                                            as: :check }
  ```

  as trigger: 

  ```ruby
  validate_column :table_name, :column_name, 
                               exclusion: { in: 1..3, 
                                            on: :create, 
                                            as: :trigger }
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
  validate_column :table_name, :column_name, presence: true
  ```

  with failure message: 

  ```ruby
  validate_column :table_name, :column_name, 
                  presence: { message: 'value should not be empty' }
  ```

  implemented as trigger: 

  ```ruby
  validate_column :table_name, :column_name, 
                  presence: { message: 'value should not be empty', 
                              as: :trigger }
  ```

  check when record is inserted only: 

  ```ruby
  validate_column :table_name, :column_name, 
                  presence: { message: 'value should not be empty', 
                              as: :trigger, 
                              on: :create }
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
  validate_column :table_name, :column_name, format: { with: /word/ }
  ```

  with failure message: 

  ```ruby
  validate_column :table_name, :column_name, 
    format: { with: /word/, 
              message: 'Column_name value should contain start word' }
  ```

  implemented as trigger:

  ```ruby
  validate_column :table_name, :column_name, 
    format: { with: /word/, 
              message: 'Column_name value should contain start word', 
              as: :trigger }
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

## Contributing to mv-postgresql
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Valeriy Prokopchuk. See LICENSE.txt for
further details.

