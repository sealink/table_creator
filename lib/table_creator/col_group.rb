module TableCreator
  class ColGroup
    include ActionView::Helpers::TagHelper

    attr_accessor :options

    def initialize(options = {})
      @options = options
    end

    def to_html
      content_tag :colgroup, options
    end
  end
end
