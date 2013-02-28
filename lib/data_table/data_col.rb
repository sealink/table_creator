module DataTable
  class DataCol
    include ActionView::Helpers::TagHelper

    attr_accessor :data, :data_type, :row, :type, :colspan, :link_to, :anchor, :options

    def initialize(data, row, type = nil)
      @row = row
      @options = {}
      if data.is_a? Hash
        @colspan = data[:colspan]
        @data = data[:data]
        @link_to = data[:link_to]
        @anchor = data[:anchor]
        @options = data.except(:colspan, :data, :link_to, :anchor)
      else
        @data = data
      end

      @data_type = case @data.class.to_s.to_sym
      when :Money
        :money
      when :Fixnum
        :number
      when :String
        :text
      else
        nil
      end
      @type = type || :data
      self
    end

    def to_csv
      if @colspan && @colspan > 1
        cols = [quote(@data)]
        (@colspan-1).times do
          cols << ''
        end
        cols
      else
        quote(@data)
      end
    end

    def quote(data)
      quoted = data.to_s.gsub('"', '\"')
      if data.to_s.include?(',')
        '"'+quoted+'"'
      else
        quoted
      end
    end

    def to_html
      col_tag = type == :header ? :th : :td
      content = data_type == :money ? data.format : data
      content = content_tag :a, content, :href => link_to if link_to
      content = content_tag :a, content, :name => anchor if anchor
      tag_class = [options[:class].presence, data_type.presence].compact.join(' ')
      attributes = options.except(:type).merge(:class => tag_class, :colspan => colspan)

      content_tag col_tag, content.to_s.gsub(/\n/, tag(:br)).html_safe, attributes
    end
  end
end
