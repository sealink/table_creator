require 'spec_helper'

describe DataTable::DataTable do
  let(:row) { ['col1', 2] }

  before do
    subject << { body: [row] }
  end

  it 'should generate csv' do
    expect(subject.to_csv).to eq 'col1,2'
  end

  it 'should generate html' do
    expect(subject.to_html).to eq(
      '<table>'\
      '<tbody>'\
      '<tr>'\
      '<td class="text">col1</td>'\
      '<td class="number">2</td>'\
      '</tr>'\
      '</tbody>'\
      '</table>'
    )
  end
end
