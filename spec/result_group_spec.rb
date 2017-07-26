require 'spec_helper'

describe DataTable::ResultGroup do
  let(:row1) { double(odd: true) }
  let(:row2) { double(odd: false) }
  let(:row3) { double(odd: true) }
  subject { DataTable::ResultGroup.new(nil, [row1, row2, row3]) }

  let(:row1_group) { subject.rows[0].group_object }
  let(:row1_rows) { subject.rows[0].rows }
  let(:row2_group) { subject.rows[1].group_object }
  let(:row2_rows) { subject.rows[1].rows }

  it 'should handle basic grouping' do
    subject.group('odd')
    expect(row1_group).to eq 'true'
    expect(row1_rows).to eq [row1, row3]
    expect(row2_group).to eq 'false'
    expect(row2_rows).to eq [row2]
  end

  it 'should order by groups name' do
    subject.group('odd', :group_name)
    expect(row1_group).to eq 'false'
    expect(row1_rows).to eq [row2]
    expect(row2_group).to eq 'true'
    expect(row2_rows).to eq [row1, row3]
  end

  it 'should order by groups row count' do
    subject.group('odd', :row_count)
    expect(row1_group).to eq 'true'
    expect(row1_rows).to eq [row1, row3]
    expect(row2_group).to eq 'false'
    expect(row2_rows).to eq [row2]
  end
end

describe DataTable::ResultGroup, 'when aggregating' do
  let(:row1) { double(odd: true, amount: Money.new(1), quantity: 1) }
  let(:row2) { double(odd: false, amount: Money.new(9), quantity: 3) }
  let(:row3) { double(odd: true, amount: Money.new(4), quantity: 4) }
  subject { DataTable::ResultGroup.new(nil, [row1, row2, row3]) }

  it 'should not allow non standard/implemented aggregates' do
    expect { subject.aggregate(amount: :avg) }.to raise_error(
      DataTable::Error,
      'Aggregation avg not implemented'
    )
  end

  it 'should aggregate on multiple levels' do
    expect(subject.sum).to be nil
    subject.aggregate(amount: :sum, quantity: :sum)
    expect(subject.sum).to eq(amount: Money.new(14), quantity: 8)
  end

  it 'should group and aggregate at each level' do
    subject.group(:odd)
    expect(subject.sum).to be nil
    subject.aggregate(amount: :sum, quantity: :sum)
    expect(subject.rows[0].group_object).to eq 'true'
    expect(subject.rows[0].sum).to eq(amount: Money.new(5), quantity: 5)
    expect(subject.rows[1].group_object).to eq 'false'
    expect(subject.rows[1].sum).to eq(amount: Money.new(9), quantity: 3)
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
