require 'spec_helper'
require 'timecop'

describe 'CLI' do
  after{
    File.delete 'out_test.csv' if File.exists? 'out_test.csv'
    File.delete 'spec/test_data/without_code_20160229.csv' if File.exists? 'spec/test_data/without_code_20160229.csv'
  }
  describe '#list' do
    context 'with valid parameter' do
      it 'without params' do
        expect{JLG::CLI.new.list}.to output(read_data).to_stdout
      end
      it 'with -p option' do
        expect{JLG::CLI.new.invoke(:list,[],{prefectures: true})}.to output(read_data 'spec/test_data/prefectures.csv').to_stdout
      end
      it 'with -o option' do
        JLG::CLI.new.invoke(:list,[],{output: 'out_test.csv'})
        expect(read_data'out_test.csv').to eq read_data
      end

      it 'with -o,-s option' do
        JLG::CLI.new.invoke(:list,[],{output: 'out_test.csv',sjis:true})
        expect(read_data'out_test.csv',sjis:true).to eq read_data('spec/test_data/japanese_local_governments_sjis.csv',sjis:true)
      end
      it 'with -o,-p,-s option' do
        JLG::CLI.new.invoke(:list,[],{output: 'out_test.csv',prefectures:true, sjis:true})
        expect(read_data'out_test.csv',sjis:true).to eq read_data('spec/test_data/prefectures_sjis.csv',sjis:true)
      end
    end

    context 'with invalid option' do
      it 'with invalid -o option' do
        expect{JLG::CLI.new.invoke(:list,[],{output: 'not/exist/output.csv'})}.to output("No such file or directory @ rb_sysopen - not/exist/output.csv\n").to_stderr
      end
    end

  end

  describe '#code' do
    context 'valid' do
      it 'with pref, name' do
        expect{JLG::CLI.new.code '大阪府','堺市'}.to output("271403\n").to_stdout
        expect{JLG::CLI.new.code '宮城県','仙台市'}.to output("041009\n").to_stdout
      end

      it 'with pref only' do
        expect{JLG::CLI.new.code '大阪府'}.to output("270008\n").to_stdout
        expect{JLG::CLI.new.code '広島県'}.to output("340006\n").to_stdout
      end
    end

    context 'invalid' do
      pending 'without param' do
        expect{JLG::CLI.new.invoke(:code,[])}.to output("code PREF_NAME NAME").to_stderr
      end

      it 'invalid code' do
        expect{JLG::CLI.new.invoke(:code,['存在しない県'])}.to output("").to_stdout
        expect{JLG::CLI.new.invoke(:code,['存在しない県','存在しない自治体'])}.to output("").to_stdout
      end
    end
  end

  describe '#data' do
    context 'valid' do
      it 'with code' do
        expect{JLG::CLI.new.invoke(:data,['270008'])}.to output("270008,大阪府,大阪府,都道府県,近畿地方,おおさかふ\n").to_stdout
        expect{JLG::CLI.new.invoke(:data,['10006'])}.to output("010006,北海道,北海道,都道府県,北海道地方,ほっかいどう\n").to_stdout
        expect{JLG::CLI.new.invoke(:data,['121029'])}.to output("121029,千葉県,千葉市花見川区,行政区,関東地方,ちばしはなみがわく\n").to_stdout
      end
    end
    context 'invalid' do
      it 'with invalid code' do
        expect{JLG::CLI.new.invoke(:data,[0])}.to output('').to_stdout
      end
    end
  end

  describe '#add_code' do
    before{
      @inputfile = 'spec/test_data/without_code.csv'
      @inputfile_custom_col_name = 'spec/test_data/custom_col_name_without_code.csv'
      @inputfile_custom_col_name_sjis = 'spec/test_data/custom_col_name_without_code_sjis.csv'
    }
    after {
      ['./without_code_20160130.csv',
       'add_code_output_test.csv'].each do|file|
        File.delete file if File.exists? file
      end
    }
    context 'exec successfully' do
      it 'without outputfile' do
        Timecop.freeze(Time.local(2016,1,30,10,0,0)){
          JLG::CLI.new.invoke(:add_code,[@inputfile])
        }
        expect(read_data'./without_code_20160130.csv').to eq read_data
      end
      it 'with outputfile' do
        JLG::CLI.new.invoke(:add_code,[@inputfile],{output:'add_code_output_test.csv'})
        expect(read_data'add_code_output_test.csv').to eq read_data
      end
      it 'custom column name' do
        JLG::CLI.new.invoke(:add_code,[@inputfile_custom_col_name],{output:'add_code_output_test.csv',pref_column:'都道府県',name_column:'自治体名'})
        expect(read_data 'add_code_output_test.csv').to eq read_data 'spec/test_data/custom_col_name_with_code.csv'
      end
      it 'custom column name sjis' do
        JLG::CLI.new.invoke(:add_code,[@inputfile_custom_col_name_sjis],{output:'add_code_output_test.csv',pref_column:'都道府県',name_column:'自治体名',sjis:true})
        expect(read_data('add_code_output_test.csv',sjis:true)).to eq read_data('spec/test_data/custom_col_name_with_code_sjis.csv',sjis:true)
      end
    end

    context 'exec unsuccessfully' do
      it 'inputfile is not found' do
        Timecop.freeze(Time.local(2016,2,6,11,0,0)){
          expect{JLG::CLI.new.invoke(:add_code,['not/exist/inputfile.csv'])}.to output("No such file or directory @ rb_sysopen - not/exist/inputfile.csv\n").to_stderr
        }
      end
      it 'outputfile path do not exist' do
        expect{JLG::CLI.new.invoke(:add_code,[@inputfile],{output:'not/exist/output.csv'})}.to output("No such file or directory @ rb_sysopen - not/exist/output.csv\n").to_stderr
      end

    end

  end
end