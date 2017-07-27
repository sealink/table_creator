module DataTable
  require 'action_view'
  require 'active_support/all'

  require 'data_table/table'
  require 'data_table/data_col'
  require 'data_table/data_row'
  require 'data_table/data_row_group'
  require 'data_table/col_group'
  require 'data_table/result_group'

  def self.formatters(type)
    @formatters ||= {}
    @formatters[type] ||= {}
  end

  def self.add_formatter(type, klass, method)
    formatters(type)[klass] = method
  end

  Error = Class.new(StandardError)
end
