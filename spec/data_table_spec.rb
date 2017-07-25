require 'spec_helper'

describe DataTable::DataTable do
  let(:row) { ['col1', 2, Money.new(3)] }
  let(:money_class) {
    Class.new do
      def initialize(dollars)
        @dollars = dollars
      end

      def format
        "$#{with_places}"
      end

      def to_s
        with_places
      end

      def with_places
        '%.2f' % @dollars
      end
    end
  }

  before do
    stub_const 'Money', money_class
    subject << { body: [row] }
  end

  it 'should generate csv' do
    expect(subject.to_csv).to eq 'col1,2,3.00'
  end

  it 'should generate html' do
    expect(subject.to_html).to eq(
      '<table>'\
      '<tbody>'\
      '<tr>'\
      '<td class="text">col1</td>'\
      '<td class="number">2</td>'\
      '<td class="money">$3.00</td>'\
      '</tr>'\
      '</tbody>'\
      '</table>'
    )
  end
end
