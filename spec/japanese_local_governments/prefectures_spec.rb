require 'spec_helper'

describe 'JLG::Prefectures' do

  describe '::list' do
    it 'output to stdout' do
      expect{JLG::Prefectures.list}.to output(read_data('spec/test_data/prefectures.csv')).to_stdout
    end
    it 'output to csv file' do
      outputfile = 'jlg_prefecture_list_test.csv'
      JLG::Prefectures.list(outputfile)
      expect(File.exist? outputfile).to be true
      expect(read_data(outputfile)).to eq read_data('spec/test_data/prefectures.csv')
      File.delete outputfile #後始末
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