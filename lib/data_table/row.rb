module DataTable
  class Row
    include ActionView::Helpers::TagHelper

    attr_accessor :cols, :parent, :options

    def initialize(row, parent, options = {})
      @parent = parent
      @options = options
      @cols  = []
      row.each do |col|
        @cols << Col.new(col, row, options[:type])
      end
      self
    end

    def to_csv
      cols.map(&:to_csv).flatten.join(',')
    end

    def to_html
      content_tag :tr, cols.map(&:to_html).join.html_safe, options.except(:type)
    end
  end
end
