require 'spec_helper'

describe DataTable::DataTable do
  before do
    @table = subject
    row = ['col1', 2]
    @table << {
      :body => [row]
    }
  end
  
  it 'should generate csv' do
    @table.to_csv.should == 'col1,2'
  end
  
  it 'should generate html' do
    @table.to_html.should ==
      '<table><tbody><tr><td class="text">col1</td><td class="number">2</td></tr></tbody></table>'
  end
end
