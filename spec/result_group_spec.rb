require 'spec_helper'

describe DataTable::ResultGroup do
  before do
    @row1 = stub(:odd => true)
    @row2 = stub(:odd => false)
    @row3 = stub(:odd => true)
    @rg = DataTable::ResultGroup.new(nil, [@row1, @row2, @row3])
  end

  it 'should handle basic grouping' do
    @rg.group('odd')
    @rg.rows[0].group_object.should == 'true'
    @rg.rows[0].rows.should == [@row1, @row3]
    @rg.rows[1].group_object.should == 'false'
    @rg.rows[1].rows.should == [@row2]
  end

  it 'should order by groups name' do
    @rg.group('odd', :group_name)
    @rg.rows[0].group_object.should == 'false'
    @rg.rows[0].rows.should == [@row2]
    @rg.rows[1].group_object.should == 'true'
    @rg.rows[1].rows.should == [@row1, @row3]
  end

  it 'should order by groups row count' do
    @rg.group('odd', :row_count)
    @rg.rows[0].group_object.should == 'true'
    @rg.rows[0].rows.should == [@row1, @row3]
    @rg.rows[1].group_object.should == 'false'
    @rg.rows[1].rows.should == [@row2]
  end
end

