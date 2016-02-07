require 'japanese_local_governments/data'
require 'date'
require 'csv'

module JLG
  class Governments
    include JLG::DATA

    # 地方自治体のリストを出力する
    # @param filename [String] 出力ファイルのパス
    def self.list(filename=nil)
      JLG.list(filename){|out|
        out.puts HEADER.join(',')
        GOV_DATA.values.each do |data|
          out.puts data.values.join(',')
        end
      }
    end

    # 都道府県名、自治体名からコードを得る
    # @param pref [String] 都道府県名
    # @param name [String] 自治体名
    # @return [String] 自治体コード。6桁。ゼロパディングあり。
    def self.code_of(pref, name=pref)
      GOV_DATA[GOV_DATA_NAME_INDEX[pref][name]][:code]
    rescue
      nil
    end

    # コードから自治体データを得る
    # @param code [String] 自治体コード。6桁。ゼロパディングあり。
    def self.data_of(code)
      GOV_DATA[code]
    end

    # 都道府県名、自治体名を持つCSVファイルを読み込み 自治体コードを付加する
    # @param inputfile [String] 自治体コードを付加したいCSVファイル
    # @param outputfile [String] 出力ファイル名。
    # @param pref [String] 都道府県カラムの名前
    # @param name [String] 自治体名カラムの名前
    def self.append_code(inputfile, outputfile=nil, pref:'pref', name: 'name')
      if outputfile.nil?
        date = Date.today.strftime('%Y%m%d')
        outputfile = './' + File.basename(inputfile,'.*') + "_#{date}.csv"
      end
      CSV.open(inputfile,headers: true,return_headers:true) do|csv|
        CSV.open(outputfile,"wb") do |out|
          csv.each do |row|
            if row.header_row?
              out<<row.headers.to_a.insert(0,'code')
            else
              code = code_of(row[pref],row[name])
              out<<row.to_h.values.insert(0,code)
            end
          end
        end
      end
    end
  end
end
