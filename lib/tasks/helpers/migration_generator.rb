require "rails/generators"
require "rails/generators/active_record"

# Implementation based on how paper_trail gem achieves similar result
# https://github.com/paper-trail-gem/paper_trail/blob/master/lib/generators/paper_trail/migration_generator.rb
class MigrationGenerator < ::Rails::Generators::Base
  include ::Rails::Generators::Migration

  # Tells Migrations where to look for template files
  source_root File.expand_path("../migration_templates", __dir__)

  # Needs to be reimplemented or throws unimplemented error
  def self.next_migration_number(dirname)
    ::ActiveRecord::Generators::Base.next_migration_number(dirname)
  end

  def generate_migration(migration_name, template_file, template_options)
    migration_directory = File.expand_path("db/migrate")

    if self.class.migration_exists?(migration_directory, migration_name)
      raise "Can't generate migration #{migration_name} because it already exists."
    end

    @template_options = template_options
    migration_template(template_file,
                       "db/migrate/#{migration_name}.rb",
                       {})
  end

  def migration_version
    format(
      "[%d.%d]",
      ::ActiveRecord::VERSION::MAJOR,
      ::ActiveRecord::VERSION::MINOR
    )
  end
end

