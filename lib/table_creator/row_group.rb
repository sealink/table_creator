# A group of rows
#
# Can be of type: [:header, :footer, :body]
module TableCreator
  class RowGroup
    include ActionView::Helpers::TagHelper

    attr_accessor :children, :parent, :options

    def initialize(row_group, parent, type = :body, options = nil)
      @parent = parent
      @children = []
      @options = options
      @type = type

      row_group.each do |row|
        if row.is_a? Hash
          @children << Row.new(row[:data], self, row.except(:data).merge(:type => type))
        else
          @children << Row.new(row, self, :type => type)
        end
      end
      self
    end

    def <<(child)
      @children << Row.new(child, self, :type => type)
    end

    def to_csv
      @children.map(&:to_csv).join("\n")
    end

    def to_html
      tag = case @type; when :header; :thead; when :footer; :tfoot; else :tbody; end
      content_tag tag, children.map(&:to_html).join.html_safe, options
    end
  end
end
