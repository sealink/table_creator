module TableCreator
  require 'action_view'
  require 'active_support/all'

  require 'table_creator/table'
  require 'table_creator/col'
  require 'table_creator/row'
  require 'table_creator/row_group'
  require 'table_creator/col_group'
  require 'table_creator/result_group'

  def self.formatters(type)
    @formatters ||= {}
    @formatters[type] ||= {}
  end

  def self.add_formatter(type, klass, method)
    formatters(type)[klass] = method
  end

  Error = Class.new(StandardError)
end
