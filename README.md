## MariaDB Temporal Tables
Adds support for MariaDB's [System-Versioned tables](https://mariadb.com/kb/en/system-versioned-tables/) 
and [Application Time periods](https://mariadb.com/kb/en/application-time-periods/) into Rails based applications

### Installation
This gem is dependant on the [composite_primary_keys](https://github.com/composite-primary-keys/composite_primary_keys) gem and needs to be installed.
Reference [the documentation](https://github.com/composite-primary-keys/composite_primary_keys#versions-) to find the correct version to use and add this to you Gemfile
```
gem 'composite_primary_keys', '=x.x.x'
```

Next also add this your Gemfile
```
gem 'mariadb_temporal_tables'
```

Then install gems by running:
```
bundle install
```

### System Versioned Tables
#### Generating Migrations
To include system versioned tables, the first step is generate a migration that adds system versioning on a database level.
This can be done manually, but rake tasks are also provided to automate this step.

To generate a simple migration for a table run this replacing table_name with your table name:
```
rails mariadb_temporal_tables:gen_migration_system -- --table=table_name
```

Additional options can also be added to utilize the full feature-set of the gem:
```
rails mariadb_temporal_tables:gen_migration_system -- --table=table_name --include_author_reference=true --include_change_list=true
```
This migration also adds columns to hold a reference for author_id as well a column for a change list of each version.
Full list of options can be found [here](#migration-generators) .

**Note: In order for author id to be referenced in versions, call `system_versioning_set_author` somewhere in the controller.**

For example:
```ruby
class ApplicationController < ActionController::Base
  before_action :set_author
  
  def set_author
    system_versioning_set_author(current_user)
  end
  
end
```
<br>

**Additional Note: Since this migration is MariaDB specific it cannot be stored in a regular `schema.rb` file. It is recommended to add this line to `config/application.rb`:**
```ruby
config.active_record.schema_format = :sql
```
This generates a `structure.sql` file instead which can hold migration results of MariaDB. [mariadb-dump/mysqldump](https://mariadb.com/kb/en/mariadb-dumpmysqldump/) need to be available on host machine running the rails application for this to succeed
<br>
<br>

#### Adding the Concern
The migration on it's own is sufficient to add support for system versioned tables. The provided concerns make usage much easier and provide several convenience methods.
To add the SystemVersioning concern to a model, just include as such:

```ruby
class YourModel < ApplicationRecord
  include MariaDBTemporalTables::SystemVersioning
  ...
end
```
This concern provides the functionality of author reference and change list generation, as well as provides a series of methods ([full list here](#methods))

The above implementation assumes all default options, options can be configured using the `system_versioning_options` method as such:
```ruby
class YourModel < ApplicationRecord
  include MariaDBTemporalTables::SystemVersioning
  system_versioning_options :exclude_change_list => [:dont_add_me_to_change_list]
  ...
end
```
A full list options can be found [here](#concern-options)

### Application Time Periods
Adding application time periods follows same procedure as system versioned tables. It is recommended you read through the previous section first.

#### Generating Migrations
First the migration has to be generated. This can be done by running:
```
rails mariadb_temporal_tables:gen_migration_application -- --table=table_name
```
Full list of options to this command found [here](#migration-generators)

#### Adding the Concern
```ruby
class YourModel < ApplicationRecord
  include MariaDBTemporalTables::ApplicationVersioning
  ...
end
```
Full list of methods [here](#methods).
Options can also be configured using the `application_versioning_options` method. Full list of options [here](#concern-options)

### Bi-temporal Tables (System and Application versioning)
Having Bi-temporal tables is also possible with this gem. First migrations should be generated for each as explained above.
Then a concern is provided to easily include both:
```ruby
class YourModel < ApplicationRecord
  include MariaDBTemporalTables::CombinedVersioning
  ...
end
```
This concern accepts both `application_versioning_options` and `system_versioning_options`. It should be noted that in the case of conflicting options, latest will always be used.

**Additional Note: By default [MariaDB disables table alterations after system versioning is added](https://mariadb.com/kb/en/system-versioned-tables/#system_versioning_alter_history).
So either make the system versioning migration the last migration of a table, or disable this feature.**

### Custom Queries
Once the migrations are complete, the full feature set of MariaDB is available to use. The provided concerns provide the most straightforward functionalities that are most commonly used. 
If the need for a more complex and custom query is needed, this can done through the `find_by_sql` [method provided by Rails](https://apidock.com/rails/v6.1.3.1/ActiveRecord/Querying/find_by_sql).
```ruby
YourModel.find_by_sql("YOUR_SQL_QUERY", [YOUR_BINDS_IF_ANY])
```
Some class instance methods are provided by the concerns that can be used in these queries `system_versioning_start_column_name`, `system_versioning_end_column_name`, `application_versioning_start_column_name`, `application_versioning_end_column_name`

### Options & Methods

#### Migration Generators
`mariadb_temporal_tables:gen_migration_system`

| option                        | type      | default             | description                                                                                                 |
|-------------------------------|-----------|---------------------|-------------------------------------------------------------------------------------------------------------|
| `--table`                     | `string`  | *none*  (required)  | Table to generate migration for                                                                             |
| `--include_change_list`       | `boolean` | `false`             | Whether change_list column should be added or not                                                           |
| `--include_author_reference`  | `boolean` | `false`             | Whether reference of author id should be added or not                                                       |
| `--author_table`              | `string`  | `users`             | Table to reference author id from                                                                           |
| `--start_column_name`         | `string`  | `transaction_start` | Name of column that represents start of period (if this is set, concern option also has to be set to match) |
| `--end_column_name`           | `string`  | `transaction_end`   | Name of column that represents end of period (if this is set, concern option also has to be set to match    |


<br>

`mariadb_temporal_tables:gen_migration_application`

| option                   | type                                | default            | description                                                                                                 |
|--------------------------|-------------------------------------|--------------------|-------------------------------------------------------------------------------------------------------------|
| `--table`                | `string`                            | *none*  (required) | Table to generate migration for                                                                             |
| `--add_columns`          | `boolean`                           | `true`             | Whether columns should be added to table or not (set to `false` when using existing columns)                |
| `--replace_primary_key`  | `boolean`                           | `true`             | Whether end column should be added to primary key or not                                                    |
| `--column_type`          | `DATE/ DATETIME/ TIMESTAMP`         | `DATE`             | Type to use for column to be added                                                                          |
| `--start_column_name`    | `string`                            | `valid_start`      | Name of column that represents start of period (if this is set, concern option also has to be set to match) |
| `--end_column_name`      | `string`                            | `valid_end`        | Name of column that represents end of period (if this is set, concern option also has to be set to match)   |


#### Concern Options

`system_versioning_options`

| option                 | type                    | default               | description                                                                                   |
|------------------------|-------------------------|-----------------------|-----------------------------------------------------------------------------------------------|
| `:start_column_name`   | `String`                | `"transaction_start"` | Name of column that represents start of period of system versioning (has to match migration)  |
| `:end_column_name`     | `String`                | `"transaction_end"`   | Name of column that represents end of period of system versioning (has to match migration)    |
| `:exclude_revert`      | `Array<String>`         | `[]`                  | Array of column names that should be excluded when reverting a record                         |
| `:exclude_change_list` | `Array<String>`         | `[]`                  | Array of column names that should be excluded when generating the change list                 |
| `:primary_key`         | `Symbol/Array<Symbol>`  | `:id`                 | Primary key to be set as the model primary key (can be single or composite key)               |

<br>

`application_versioning_options`

| option                 | type                    | default                   | description                                                                                       |
|------------------------|-------------------------|---------------------------|---------------------------------------------------------------------------------------------------|
| `:start_column_name`   | `String`                | `"valid_start"`           | Name of column that represents start of period of application versioning (has to match migration) |
| `:end_column_name`     | `String`                | `"valid_end"`             | Name of column that represents end of period of application versioning (has to match migration)   |
| `:primary_key`         | `Symbol/Array<Symbol>`  | `[:id, end_column_name]`  | Primary key to be set as the model primary key (can be single or composite key)                   |


#### Methods

`SystemVersioning`

| method                      | class or instance method | description                                                                         |
|-----------------------------|--------------------------|-------------------------------------------------------------------------------------|
| `versions`                  | instance                 | Get all the previous versions of a record                                           |
| `revert `                   | instance                 | Revert the current object to a specific version of an object with given id and time |
| `all_as_of`                 | class                    | Equivalent to rails `all` but with a given as of time                               |
| `order_as_of`               | class                    | Equivalent to rails `order` but with a given as of time                             |
| `where_as_of`               | class                    | Equivalent to rails `where` but with a given as of time                             |
| `find_as_of`                | class                    | Equivalent to rails `find` but with a given as of time                              |
| `versions_count_for_author` | class                    | Gets the number of versions that an author has created                              |

<br>

`ApplicationVesioning`

| method                       | class or instance method | description                                             |
|------------------------------|--------------------------|---------------------------------------------------------|
| `all_valid_at`               | class                    | Equivalent to rails `all` but with a given valid time   |
| `order_valid_at`             | class                    | Equivalent to rails `order` but with a given valid time |
| `where_valid_at`             | class                    | Equivalent to rails `where` but with a given valid time |


<br>

`CombinedVersioning`

| method                 | class or instance method | description                                                              |
|------------------------|--------------------------|--------------------------------------------------------------------------|
| `all_valid_at_as_of`   | class                    | Combined functionality of `all` from system and application versioning   |
| `order_valid_at_as_of` | class                    | Combined functionality of `order` from system and application versioning |
