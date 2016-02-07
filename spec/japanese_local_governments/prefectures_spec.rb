require 'spec_helper'

describe 'JLG::Prefectures' do

  describe '::list' do
    before{
      @outputfile = 'jlg_prefecture_list_test.csv'
    }
    after {
      File.delete @outputfile if File.exist? @outputfile #後始末
    }
    it 'output to stdout' do
      expect{JLG::Prefectures.list}.to output(read_data('spec/test_data/prefectures.csv')).to_stdout
    end
    it 'output to csv file' do
      JLG::Prefectures.list(@outputfile)
      expect(File.exist? @outputfile).to be true
      expect(read_data(@outputfile)).to eq read_data('spec/test_data/prefectures.csv')
    end
    it 'output to csv file in sjis' do
      outputfile = 'jlg_prefecture_list_test.csv'
      JLG::Prefectures.list(@outputfile,sjis:true)
      expect(File.exist? @outputfile).to be true
      expect(read_data(@outputfile,sjis:true)).to eq read_data('spec/test_data/prefectures_sjis.csv',sjis:true)

    end
  end

  describe '::list_of' do
    context 'with valid parameter' do
      it {
        expect{JLG::Prefectures.list_of('宮城県')}.to output(read_data('spec/test_data/miyagiken.csv')).to_stdout
      }
    end
    context 'with invalid parameter' do
      it {
        expect(JLG::Prefectures.list_of('存在しない県')).to be_nil
      }
    end

  end

  describe '::code_of' do
    context 'with valid parameter' do
      it{
        expect(JLG::Prefectures.code_of '北海道').to be 1
        expect(JLG::Prefectures.code_of '大阪府').to be 27
        expect(JLG::Prefectures.code_of '広島県').to be 34
      }
    end
    context 'with invalid parameter' do
      it {
        expect(JLG::Prefectures.code_of '存在しない県').to be_nil
      }
    end

  end


end