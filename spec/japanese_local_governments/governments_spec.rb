require 'spec_helper'
require 'timecop'

describe 'JLG::Governments' do

  describe '::list' do
    it 'output to stdout' do
      expect{JLG::Governments.list}.to output(read_data).to_stdout
    end
    it 'output to csv file' do
      outputfile = 'jlg_governments_list_test.csv'
      JLG::Governments.list(outputfile)
      expect(File.exist? outputfile).to be true
      expect(read_data(outputfile)).to eq read_data
      File.delete outputfile #後始末
    end
    it "output path doesn't exist" do
      outputfile = 'not/exist/output.csv'
      expect{JLG::Governments.list(outputfile)}.to raise_error
    end
  end

  describe '::code_of' do
    context 'with valid paramenter' do
      it{
        expect(JLG::Governments.code_of '北海道','北海道').to eq '010006'
        expect(JLG::Governments.code_of '北海道').to eq '010006'
      }
    end
    context 'with invalid parameter' do
      it{
        expect(JLG::Governments.code_of '存在しない県','存在しない自治体').to be_nil
        expect(JLG::Governments.code_of '存在しない県').to be_nil
      }
    end
  end

  describe '::data_of' do
    context 'valid' do
      it {
        result = {code:'270008',pref:'大阪府',name:'大阪府',type:'都道府県',district:'近畿地方',furigana:'おおさかふ'}
        expect(JLG::Governments.data_of(270008)).to eq result
      }
    end
    context 'invalid' do
      it {
        expect(JLG::Governments.data_of(0)).to be_nil
      }
    end
  end

  describe '::append_code' do
    after{
      File.delete 'out_test.csv' if File.exists? 'out_test.csv'
      File.delete './without_code_20160229.csv' if File.exists? './without_code_20160229.csv'
    }
    context 'exec successfully' do
      it 'with inputfile only' do
        Timecop.freeze(Time.local(2016, 2, 29, 10, 5, 0)){
          JLG::Governments.append_code('spec/test_data/without_code.csv')
        }
        expect(read_data'./without_code_20160229.csv').to eq read_data
      end
      it 'with outputfile' do
        JLG::Governments.append_code('spec/test_data/without_code.csv', 'out_test.csv')
        expect(read_data'out_test.csv').to eq read_data
      end

      it 'with pref,neme' do
        JLG::Governments.append_code('spec/test_data/custom_col_name_without_code.csv', 'out_test.csv', pref:'都道府県', name:'自治体名')
        expect(read_data'out_test.csv').to eq read_data('spec/test_data/custom_col_name_with_code.csv')
      end
    end

    context 'exec unsuccessfully' do
      it 'inputfile not found' do
        expect{JLG::Governments.append_code('not/exist/inputfile.csv')}.to raise_error
      end
      it 'outputfile path not exist' do
        expect{JLG::Governments.append_code('spec/test_data/without_code.csv','not/exist/output.csv')}.to raise_error
      end
    end

  end

end