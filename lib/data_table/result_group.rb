module DataTable
  class ResultGroup
    attr_accessor :group_object, :rows
    attr_accessor :level, :total_levels
    attr_accessor :sum

    def initialize(group_object, rows, total_levels = 0)
      @group_object = (group_object.blank? && group_object != false) ? nil : group_object.to_s
      @rows  = rows
      @level = 0
      @total_levels = total_levels
    end


    def level=(new_level)
      @level = new_level
      @rows.each do |row|
        if row.is_a? ResultGroup
          row.total_levels = @total_levels
          row.level = new_level + 1
        end
      end
    end


    def count
      @rows.map { |r| r.is_a?(self.class) ? r.count : 1 }.sum
    end


    def group(groups, order = nil)
      groups = [groups] unless groups.is_a?(Array)

      return if groups.empty?
      new_rows = []

      first_group = groups.shift
      new_group = if @rows.first.is_a? ResultGroup
        @rows.map{|rg| [rg.group_object, rg.group_children(first_group, order)]}
      else
        if first_group == true
          {'All' => @rows}
        elsif first_group.is_a?(Hash)
          @rows.group_by{|r|
            r.send(first_group.keys.first).send(first_group.values.first)
          }
        else
          @rows.group_by{|r| r.send(first_group)}
        end
      end

      new_group = case order.try(:to_sym)
      when :group_name
        Hash[new_group.sort { |a,b| a.first.to_s <=> b.first.to_s }]
      when :row_count
        Hash[new_group.sort { |a,b| b.last.size <=> a.last.size }]
      else
        new_group
      end

      @total_levels += 1
      new_group.each do |group, rows|
        r = ResultGroup.new(group, rows, @total_levels)
        r.level = @level + 1
        new_rows << r
      end

      @rows = new_rows
      group(groups, order) unless groups.empty?
      @rows
    end


    def group_children(group, order = nil)
      if @rows.first.is_a?(ResultGroup)
        @rows.each{|r| r.group_children(group, order)}
        @rows
      else
        self.group(group, order)
      end
    end


    # fields is a hash where:
    #   key is the field/method
    #   value is the aggregate type (currently only :sum)
    def aggregate(fields)
      invalid_aggregates = fields.values.uniq - [:sum]
      raise Exception.new("Aggregation #{invalid_aggregates.to_sentence} not implemented") if invalid_aggregates.present?

      @sum ||= {}

      fields.each do |field, aggregation|
        @sum[field] = 0

        @rows.each do |row|

          if row.is_a? ResultGroup
            # agregate each lower levels
            row.aggregate(fields)

            case aggregation
            when :sum
              @sum[field] += row.sum[field]
            end

          else
            case aggregation
            when :sum
              @sum[field] += (row.send(field) || 0) # encase result is nil
            end
          end
        end
      end
    end


    def to_data_rows(&block)
      rows = []
      @rows.each do |row|
        if row.is_a? ResultGroup

          sub_rows = row.to_data_rows(&block)
          format = block.call(row, nil)

          if format.is_a? Hash
            group_data = format[:group]
            group_summary_data = format[:summary]
          elsif format.is_a? Array
            group_data = nil
            group_summary_data = format
          end

          if group_data.is_a? Array
            rows << {:class => "d#{@total_levels-row.level} l#{@total_levels} group", :data => group_data}
          elsif group_data.is_a? Hash
            rows << group_data.merge(:class => "h#{row.level}")
          end

          if group_summary_data.is_a? Array
            rows << {:class => "d#{@total_levels-row.level} l#{@total_levels} summary", :data => group_summary_data}
          elsif group_summary_data.is_a? Hash
            rows << group_summary_data.merge(:class => "h#{row.level}")
          end

          rows += sub_rows
        else
          format = block.call(nil, row)

          if format.is_a? Hash
            if format[:data].first.is_a? Array
              format[:data].each do |row|
                rows << row
              end
            else
              rows << format[:data]
            end
            
          elsif format.is_a? Array
            rows << format
          end
        end
      end
      rows
    end
  end
end
