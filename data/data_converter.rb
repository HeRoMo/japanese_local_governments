require 'excel2csv'
require 'nkf'

# String にメソッドを追加する
module Hiragana
  refine String do
    # 半角カナをひらがなに変換する
    def to_hiragana
      NKF.nkf("-wX --hiragana", self)
    end
  end
end

# 総務省の[全国地方公共団体コード](http://www.soumu.go.jp/denshijiti/code.html) を
# 読み込んでdataを生成するためのコンバータクラス
class DataConverter
  using Hiragana

  # シート1のカラム名=カラム位置
  CODE6 = 0
  PREF = 1
  NAME = 2
  PREF_KANA = 3
  NAME_KANA = 4

  # シート2のカラム名=カラム位置
  S2_CODE6 = 0
  S2_NAME = 1
  S2_NAME_KANA = 2

  # コンストラクタ
  # @param [String] filename 読み込むExcelファイルのパス
  def initialize(filename)
    @filename = filename
  end

  # 指定されたファイルを読み込む
  # @param [String] 読み込むExcelファイルのパス
  def read_data(filename = @filename)
    @pref_data = {}
    @gov_data = {}
    @gov_data_name_index ={}

    # シート１(基礎自治体)を読み込む
    first_row = true
    Excel2CSV.foreach(filename) do |line|
      if first_row
        first_row = false
        next
      end
      data = convert_to_hash line
      @gov_data[data[:code]] = data
      @pref_data[data[:code][0,2]] = data if data[:type]=='都道府県'
    end

    # シート２(政令指定都市)を読み込む
    Excel2CSV.foreach(filename, sheet:1) do |line|
      next if @gov_data[line[S2_CODE6]] # すでにデータがある code はスキップ
      data = convert_to_hash_for_gyouseiku line
      @gov_data[data[:code]] = data
    end

    # 要素のソート
    tmp_data = @gov_data.sort
    @gov_data = {}
    tmp_data.each do |elm|
      @gov_data[elm[0]] = elm[1]
    end

    @gov_data.each do |k, v|
      data = v
      @gov_data_name_index[data[:pref]] ||= {}
      @gov_data_name_index[data[:pref]][data[:name]] = data[:code]
    end
  end

  # CSVのデータからRubyのモジュールを生成する。
  # モジュールには定数でデータを定義する。
  # そうすることで、CSVから読むよりかなり高速にデータを取り出せる
  # @param template [String] テンプレートファイル名
  # @param output [String] 出力先のファイル名
  def make_data_module(
      template:'./data/jlg_data_template.erb',
      output:'../lib/japanese_local_governments/data.rb')
    require 'erb'
    erb = ERB.new(File.read(template),nil,'-')
    open(output, 'wb') do |file|
      file.puts erb.result(binding)
    end
  end

  private
  # 自治体データ(シート1)をハッシュに変換する
  # @param [Array] 読み込むExcelの行データ
  def convert_to_hash(row)
    {
        code: row[CODE6],
        pref: row[PREF],
        name: row[NAME]||row[PREF],
        type: type(row),
        district: district(row[CODE6]),
        furigana: (row[NAME_KANA]||row[PREF_KANA]).to_hiragana
    }
  end

  # 自治体データ(シート2)をハッシュに変換する
  # @param [Array] 読み込むExcelの行データ
  def convert_to_hash_for_gyouseiku(row)
    pref_code = row[S2_CODE6][0,2]
    data = @pref_data[pref_code].dup
    data[:code] = row[S2_CODE6]
    data[:name] = row[S2_NAME]
    data[:furigana] = row[S2_NAME_KANA]
    data[:type] = '行政区'
    data
  end

  # 自治体のタイプを判定する
  # @param [Array] 読み込むExcelの行データ
  def type(row)
    code = row[CODE6][2,3].to_i
    case code
      when 0 then return '都道府県'
      when (100..199)
        if row[CODE6][0,2] == '13'
          return '特別区'
        else
          return '政令市'
        end
      when (201..299) then return row[NAME][-1]
      when (301..799) then return row[NAME][-1]
    end
  end

  # 地方を判定する
  # @param [String] 6桁の自治体コード
  def district(code6)
    code = code6[0,2].to_i
    case code
      when 1        then return '北海道地方'
      when (2..7)   then return '東北地方'
      when (8..14)  then return '関東地方'
      when (15..23) then return '中部地方'
      when (24..30) then return '近畿地方'
      when (31..35) then return '中国地方'
      when (36..39) then return '四国地方'
      when (40..47) then return '九州地方'
    end
  end
end


if __FILE__ == $0

  dc = DataConverter.new '000318342.xls'
  dc.read_data
  dc.make_data_module

end