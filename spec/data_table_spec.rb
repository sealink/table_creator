require 'spec_helper'

describe DataTable::Table do
  let(:row) { ['col1', 2, Money.new(3), Booking.new(42, '22TEST')] }
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
  let(:booking_class) {
    Class.new do
      attr_reader :id, :reference

      def initialize(id, reference)
        @id = id
        @reference = reference
      end
    end
  }

  before do
    stub_const 'Money', money_class
    stub_const 'Booking', booking_class
    DataTable.add_formatter :html, Money, proc { |money| money.format }
    DataTable.add_formatter :html, Booking, proc { |booking|
      { link_to: "/bookings/#{booking.id}", data: booking.reference }
    }
    DataTable.add_formatter :csv, Money, proc { |money| money.to_s }
    DataTable.add_formatter :csv, Booking, :reference

    subject << { body: [row] }
  end

  it 'should generate csv' do
    expect(subject.to_csv).to eq 'col1,2,3.00,22TEST'
  end

  it 'should generate html' do
    expect(subject.to_html).to eq(
      '<table>'\
      '<tbody>'\
      '<tr>'\
      '<td class="text">col1</td>'\
      '<td class="number">2</td>'\
      '<td class="money">$3.00</td>'\
      '<td class="booking"><a href="/bookings/42">22TEST</a></td>'\
      '</tr>'\
      '</tbody>'\
      '</table>'
    )
  end
end
