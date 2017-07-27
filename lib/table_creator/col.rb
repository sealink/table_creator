module TableCreator
  class Col
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
      formatted_data = format_csv(data)
      quoted = formatted_data.to_s.gsub('"', '\"')
      if formatted_data.to_s.include?(',')
        '"'+quoted+'"'
      else
        quoted
      end
    end

    def to_html
      formatter = TableCreator.formatters(:html)[@data.class]
      content = if formatter
        result = formatter.is_a?(Symbol) ? @data.send(formatter) : formatter.call(@data)
        if result.is_a?(Hash)
          link_to = result[:link_to]
          anchor  = result[:anchor]
          @options[:class] ||= @data.class.name.underscore
          result.fetch(:data)
        else
          @options[:class] ||= @data.class.name.underscore
          result
        end
      else
        @data
      end
      col_tag = type == :header ? :th : :td
      content = content_tag :a, content, :href => link_to if link_to
      content = content_tag :a, content, :name => anchor if anchor
      tag_class = [options[:class].presence, data_type.presence].compact.join(' ')
      attributes = options.except(:type).merge(:class => tag_class, :colspan => colspan)

      content_tag col_tag, content.to_s.gsub(/\n/, tag(:br)).html_safe, attributes
    end

    private

    def format_csv(data)
      formatter = TableCreator.formatters(:csv)[data.class]
      return data unless formatter
      result = formatter.is_a?(Symbol) ? @data.send(formatter) : formatter.call(@data)
      if result.is_a?(Hash)
        result.fetch(:data)
      else
        result
      end
    end
  end
end
