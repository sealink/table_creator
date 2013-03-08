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

describe DataTable::ResultGroup, 'when aggregating' do
  before do
    @row1 = stub(:odd => true, :amount => Money.new(1), :quantity => 1)
    @row2 = stub(:odd => false, :amount => Money.new(9), :quantity => 3)
    @row3 = stub(:odd => true, :amount => Money.new(4), :quantity => 4)
    @rg = DataTable::ResultGroup.new(nil, [@row1, @row2, @row3])
  end

  it 'should not allow non standard/implemented aggregates' do
    expect {
      @rg.aggregate(:amount => :avg)
    }.to raise_error(DataTable::Exception, 'Aggregation avg not implemented')
  end

  it 'should aggregate on multiple levels' do
    @rg.sum.should be_nil
    @rg.aggregate(:amount => :sum, :quantity => :sum)
    @rg.sum.should == {:amount => Money.new(14), :quantity => 8}
  end

  it 'should group and aggregate at each level' do
    @rg.group(:odd)
    @rg.sum.should be_nil
    @rg.aggregate(:amount => :sum, :quantity => :sum)
    @rg.rows[0].group_object.should == 'true'
    @rg.rows[0].sum.should == {:amount => Money.new(5), :quantity => 5}
    @rg.rows[1].group_object.should == 'false'
    @rg.rows[1].sum.should == {:amount => Money.new(9), :quantity => 3}
  end
end

class Money
  attr_accessor :cents
  def initialize(cents)
    @cents = cents
  end

  def +(money)
    Money.new(@cents + money.cents)
  end

  def ==(money)
    @cents == money.cents
  end

  def <=>(money)
    @cents <=> money.cents
  end
end
