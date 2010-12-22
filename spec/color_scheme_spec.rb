require "#{File.dirname(__FILE__)}/spec_helper"

describe 'color_scheme' do
  
  specify 'table should be populated' do
    ColorScheme.all.first.class.should == ColorScheme
  end

  specify 'should have a default' do
    ColorScheme.get('default').should_not == nil
  end

  specify 'should return have :sharp for A' do
    ColorScheme.get('default').color_for(SongKey.KEY(:A)).should == :sharp
  end
end