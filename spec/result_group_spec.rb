require 'spec_helper'

describe TableCreator::ResultGroup do
  let(:row1) { double(odd: true) }
  let(:row2) { double(odd: false) }
  let(:row3) { double(odd: true) }
  subject { TableCreator::ResultGroup.new(nil, [row1, row2, row3]) }

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

describe TableCreator::ResultGroup, 'when aggregating' do
  let(:row1) { double(odd: true, amount: Money.new(1), quantity: 1) }
  let(:row2) { double(odd: false, amount: Money.new(9), quantity: 3) }
  let(:row3) { double(odd: true, amount: Money.new(4), quantity: 1) }
  subject { TableCreator::ResultGroup.new(nil, [row1, row2, row3]) }

  it 'should not allow non standard/implemented aggregates' do
    expect { subject.aggregate(amount: :avg) }.to raise_error(
      TableCreator::Error,
      'Aggregation avg not implemented'
    )
  end

  it 'should aggregate on multiple levels' do
    expect(subject.sum).to be nil
    subject.aggregate(amount: :sum, quantity: :sum)
    expect(subject.sum).to eq(amount: Money.new(14), quantity: 5)
  end

  it 'should group and aggregate at each level' do
    subject.group(:odd)
    expect(subject.sum).to be nil
    subject.aggregate(amount: :sum, quantity: :sum)
    expect(subject.rows[0].group_object).to eq 'true'
    expect(subject.rows[0].sum).to eq(amount: Money.new(5), quantity: 2)
    expect(subject.rows[1].group_object).to eq 'false'
    expect(subject.rows[1].sum).to eq(amount: Money.new(9), quantity: 3)
  end

  context 'to_data_rows' do
    subject {
      result = TableCreator::ResultGroup.new(nil, [row1, row2, row3])
      result.group([:odd, :quantity])
      result.to_data_rows do |row_group, row|
        [row_group.try(:group_object), row]
      end
    }

    specify do
      expect(subject).to eq [
        { class: 'd1 l2 summary', data: ['true', nil] },
        { class: 'd0 l2 summary', data: ['1', nil] },
        [nil, row1],
        [nil, row3],
        { class: 'd1 l2 summary', data: ['false', nil] },
        { class: 'd0 l2 summary', data: ['3', nil] },
        [nil, row2]
      ]
    end
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
