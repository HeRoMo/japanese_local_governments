require 'spec_helper'
require './data/data_converter.rb'

describe DataConverter do
  before(:all) do
    @dc = DataConverter.new("./data/000442937.xls")
    @dc.read_data
  end

  describe "#read_data" do
    context "makes @pref_data valid" do
      subject{@dc.instance_variable_get(:@pref_data)}
      it{ expect(subject.size).to be 47 }
      it{ expect(subject['01'][:pref]).to eq '北海道'}
    end
  end

  describe "#make_data_module" do
    before(:all) do
      @test_module_file = './data/data_converter_test.rb'
      @dc.make_data_module(output:@test_module_file)
      class Test
        JLG.module_eval{remove_const :DATA} # 一旦、正規のモジュールを削除
        # テスト用に生成したモジュールの読み込み
        require './data/data_converter_test.rb'
        include JLG::DATA
      end
      @conv_test = Test.new
    end
    after(:all) do
      File.delete @test_module_file
    end

    describe '::HEADER' do
      it {expect(Test::HEADER).to eq ['code','pref','name','type','district','furigana']}
    end

    describe "::GOV_DATA" do
      subject{Test::GOV_DATA}
      it 'has 1963 values' do
        expect(subject.keys.size).to be 1963
      end
      it 'has {Fixnum=>hash} stracture' do
        subject.each do |code, data|
          expect(code.class).to be Fixnum
          expect(data.key?(:code)).to be true
          expect(data.key?(:pref)).to be true
          expect(data.key?(:name)).to be true
          expect(data.key?(:type)).to be true
          expect(data.key?(:district)).to be true
          expect(data.key?(:furigana)).to be true
        end
      end
    end

    describe '::GOV_DATA_NAME_INDEX' do
      subject{Test::GOV_DATA_NAME_INDEX}
      it 'has 47 prefs data' do
        expect(subject.keys.size).to be 47
      end

      it 'has {String => {String => Fixnum}} structure' do
        subject.each do |key,val|
          expect(key.class).to be String
          expect(val.class).to be Hash
          val.each do |k,v|
            expect(k.class).to be String
            expect(v.class).to be Fixnum
          end
        end
      end
    end
  end

  describe '#convert_to_hash' do
    context 'convert local gov' do
      let(:row){['011002','北海道','札幌市', 'ﾎｯｶｲﾄﾞｳ', 'ｻｯﾎﾟﾛｼ']}
      it{ expect(@dc.send(:convert_to_hash,row)[:code]).to eq row[0]}
      it{ expect(@dc.send(:convert_to_hash,row)[:pref]).to eq row[1]}
      it{ expect(@dc.send(:convert_to_hash,row)[:name]).to eq row[2]}
      it{ expect(@dc.send(:convert_to_hash,row)[:type]).to eq '政令市'}
      it{ expect(@dc.send(:convert_to_hash,row)[:district]).to eq '北海道地方'}
      it{ expect(@dc.send(:convert_to_hash,row)[:furigana]).to eq 'さっぽろし'}
    end
    context 'convert pref' do
      let(:row){["150002","新潟県","","","ﾆｲｶﾞﾀｹﾝ"]}
      it{ expect(@dc.send(:convert_to_hash,row)[:code]).to eq row[0]}
      it{ expect(@dc.send(:convert_to_hash,row)[:pref]).to eq row[1]}
      it{ expect(@dc.send(:convert_to_hash,row)[:name]).to eq row[2]}
      it{ expect(@dc.send(:convert_to_hash,row)[:type]).to eq '都道府県'}
      it{ expect(@dc.send(:convert_to_hash,row)[:district]).to eq '中部地方'}
      it{ expect(@dc.send(:convert_to_hash,row)[:furigana]).to eq 'にいがたけん'}
    end
  end

  describe '#convert_to_hash_for_gyouseiku' do
    let(:row){['041017','仙台市青葉区','せんだいしあおばく']}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:code]).to eq row[0]}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:pref]).to eq '宮城県'}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:name]).to eq row[1]}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:type]).to eq '行政区'}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:district]).to eq '東北地方'}
    it{ expect(@dc.send(:convert_to_hash_for_gyouseiku,row)[:furigana]).to eq row[2]}
  end

  describe '#type' do
    context 'pref' do
      let(:row){['410004','佐賀県','','ｻｶﾞｹﾝ']}
      it {expect(@dc.send(:type,row)).to eq '都道府県'}
    end
    context 'ordinance-designated city' do
      let(:row){['011002','北海道','札幌市', 'ﾎｯｶｲﾄﾞｳ', 'ｻｯﾎﾟﾛｼ']}
      it {expect(@dc.send(:type,row)).to eq '政令市'}
    end
    context 'city' do
      let(:row){['472107','沖縄県','糸満市','ｵｷﾅﾜｹﾝ','ｲﾄﾏﾝｼ']}
      it {expect(@dc.send(:type,row)).to eq '市'}
    end
    context 'special ward' do
      let(:row){['131130','東京都','渋谷区','ﾄｳｷｮｳﾄ','ｼﾌﾞﾔｸ']}
      it {expect(@dc.send(:type,row)).to eq '特別区'}
    end
    context 'town' do
      let(:row){['163431','富山県','朝日町','ﾄﾔﾏｹﾝ','ｱｻﾋﾏﾁ']}
      it {expect(@dc.send(:type,row)).to eq '町'}
    end
    context 'village' do
      let(:row){['216046','岐阜県','白川村','ｷﾞﾌｹﾝ','ｼﾗｶﾜﾑﾗ']}
      it {expect(@dc.send(:type,row)).to eq '村'}
    end
  end

  describe '#district' do
    it '北海道'   do expect(@dc.send(:district,'010006')).to eq '北海道地方' end
    it '青森県'   do expect(@dc.send(:district,'020001')).to eq '東北地方' end
    it '岩手県'   do expect(@dc.send(:district,'030007')).to eq '東北地方' end
    it '宮城県'   do expect(@dc.send(:district,'040002')).to eq '東北地方' end
    it '秋田県'   do expect(@dc.send(:district,'050008')).to eq '東北地方' end
    it '山形県'   do expect(@dc.send(:district,'060003')).to eq '東北地方' end
    it '福島県'   do expect(@dc.send(:district,'070009')).to eq '東北地方' end
    it '茨城県'   do expect(@dc.send(:district,'080004')).to eq '関東地方' end
    it '栃木県'   do expect(@dc.send(:district,'090000')).to eq '関東地方' end
    it '群馬県'   do expect(@dc.send(:district,'100005')).to eq '関東地方' end
    it '埼玉県'   do expect(@dc.send(:district,'110001')).to eq '関東地方' end
    it '千葉県'   do expect(@dc.send(:district,'120006')).to eq '関東地方' end
    it '東京都'   do expect(@dc.send(:district,'130001')).to eq '関東地方' end
    it '神奈川県' do expect(@dc.send(:district,'140007')).to eq '関東地方' end
    it '新潟県'   do expect(@dc.send(:district,'150002')).to eq '中部地方' end
    it '富山県'   do expect(@dc.send(:district,'160008')).to eq '中部地方' end
    it '石川県'   do expect(@dc.send(:district,'170003')).to eq '中部地方' end
    it '福井県'   do expect(@dc.send(:district,'180009')).to eq '中部地方' end
    it '山梨県'   do expect(@dc.send(:district,'190004')).to eq '中部地方' end
    it '長野県'   do expect(@dc.send(:district,'200000')).to eq '中部地方' end
    it '岐阜県'   do expect(@dc.send(:district,'210005')).to eq '中部地方' end
    it '静岡県'   do expect(@dc.send(:district,'220001')).to eq '中部地方' end
    it '愛知県'   do expect(@dc.send(:district,'230006')).to eq '中部地方' end
    it '三重県'   do expect(@dc.send(:district,'240001')).to eq '近畿地方' end
    it '滋賀県'   do expect(@dc.send(:district,'250007')).to eq '近畿地方' end
    it '京都府'   do expect(@dc.send(:district,'260002')).to eq '近畿地方' end
    it '大阪府'   do expect(@dc.send(:district,'270008')).to eq '近畿地方' end
    it '兵庫県'   do expect(@dc.send(:district,'280003')).to eq '近畿地方' end
    it '奈良県'   do expect(@dc.send(:district,'290009')).to eq '近畿地方' end
    it '和歌山県' do expect(@dc.send(:district,'300004')).to eq '近畿地方' end
    it '鳥取県'   do expect(@dc.send(:district,'310000')).to eq '中国地方' end
    it '島根県'   do expect(@dc.send(:district,'320005')).to eq '中国地方' end
    it '岡山県'   do expect(@dc.send(:district,'330001')).to eq '中国地方' end
    it '広島県'   do expect(@dc.send(:district,'340006')).to eq '中国地方' end
    it '山口県'   do expect(@dc.send(:district,'350001')).to eq '中国地方' end
    it '徳島県'   do expect(@dc.send(:district,'360007')).to eq '四国地方' end
    it '香川県'   do expect(@dc.send(:district,'370002')).to eq '四国地方' end
    it '愛媛県'   do expect(@dc.send(:district,'380008')).to eq '四国地方' end
    it '高知県'   do expect(@dc.send(:district,'390003')).to eq '四国地方' end
    it '福岡県'   do expect(@dc.send(:district,'400009')).to eq '九州地方' end
    it '佐賀県'   do expect(@dc.send(:district,'410004')).to eq '九州地方' end
    it '長崎県'   do expect(@dc.send(:district,'420000')).to eq '九州地方' end
    it '熊本県'   do expect(@dc.send(:district,'430005')).to eq '九州地方' end
    it '大分県'   do expect(@dc.send(:district,'440001')).to eq '九州地方' end
    it '宮崎県'   do expect(@dc.send(:district,'450006')).to eq '九州地方' end
    it '鹿児島県' do expect(@dc.send(:district,'460001')).to eq '九州地方' end
    it '沖縄県'   do expect(@dc.send(:district,'470007')).to eq '九州地方' end
    it '不正な値' do expect(@dc.send(:district,'48')).to be nil end
  end

end