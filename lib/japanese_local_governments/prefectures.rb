require 'japanese_local_governments/data'

module JLG
  class Prefectures
    include JLG::DATA

    # 都道府県リストを出力する
    # @param filename [String] 出力先ファイルのパス
    # @param sjis [Boolean] Shift_JISで出力する場合に true とする
    def self.list(filename=nil,sjis:false)
      JLG.list(filename,sjis:sjis){|out|
        out.puts HEADER.join(',')
        GOV_DATA_NAME_INDEX.each do |key,value|
          out.puts GOV_DATA[value[key]].values.join(',')
        end
      }
    end

    # 都道府県内の自治体のリストを出力する
    # @param pref [String] 都道府県名
    def self.list_of(pref, filename=nil)
      return nil if GOV_DATA_NAME_INDEX[pref].nil?
      JLG.list(filename){|out|
        out.puts HEADER.join(',')
        GOV_DATA_NAME_INDEX[pref].each do |key,value|
          next if key == pref
          out.puts GOV_DATA[value].values.join(',')
        end
      }
    end

    # 都道府県名から都道府県コードを取得する
    # @param pref [String] 都道府県名
    # @return [Integer] 都道府県コード。2桁。ゼロパティングあり。
    def self.code_of(pref)
      GOV_DATA_NAME_INDEX[pref][pref]/10000.floor
    rescue
      nil
    end
  end
end

