require 'csv'

class JLGUtils
  @@gov_data = nil
  @@gov_data_name_index = nil

  def initialize
    read_data 'japanese_local_governments.csv' if @@gov_data.nil?
  end

  def data
    # puts @@gov_data

    start = Time.now
    10000.times {
      GOV_DATA[@@gov_data_name_index['沖縄県']['那覇市']]
    }
    puts Time.now - start

  end

  # CSVのデータからRubyのモジュールを生成する。
  # モジュールには定数でデータを定義する。
  # そうすることで、CSVから読むよりかなり高速にデータを取り出せる
  def make_data_module
    open('../lib/japanese_local_governments/data.rb', 'wb') do |file|
      file.puts 'module JLG'
      file.puts "\tmodule DATA"

      file.puts "\t\t# カラム名"
      file.puts "\t\tHEADER=['code','pref','name','type','district','furigana']"

      file.puts "\t\t# 地方自治体データのマスター"
      file.puts "\t\tGOV_DATA={"
      @@gov_data.each do |k,v|
        file.puts "\t\t\t#{k.to_i}=>#{v.map{|key,val|[key.to_sym,val]}.to_h},"
      end
      file.puts "\t\t}"

      file.puts "\t\t# 地方自治体の名前でデータを引くためインデックス 都道府県、自治体名でコードを取得できる"
      file.puts "\t\tGOV_DATA_NAME_INDEX={"
      @@gov_data_name_index.each do |key,value|
        file.puts "\t\t\t'#{key}'=>{"
        value.each do |k,v|
          file.puts "\t\t\t\t'#{k}'=>#{v.to_i},"
        end
        file.puts "\t\t\t},"
      end
      file.puts "\t\t}"

      file.puts "\t\t# 地方"

      file.puts "\tend"
      file.puts 'end'
    end
  end


  private
  def read_data(filename)
    @@gov_data = {}
    @@gov_data_name_index ={}
    CSV.foreach(filename, headers: true) do |line|
      data = line.to_hash
      @@gov_data[data['code']] = data
      @@gov_data_name_index[data['pref']] ||= {}
      @@gov_data_name_index[data['pref']][data['name']] = data['code']
    end
  end

  def add_data(file, name, comment)
    file.puts "\t\t# #{comment}"
    file.puts "\t\t#{name}={"
    # @@gov_data_name_index.each do |key,value|
    #   file.puts "\t\t\t'#{key}'=>{"
    #   value.each do |k,v|
    #     file.puts "\t\t\t\t'#{k}'=>#{v.to_i},"
    #   end
    #   file.puts "\t\t\t},"
    # end
    yield(file)
    file.puts "\t\t}"

  end

end

if __FILE__ == $0
  require 'pp'
  u = JLGUtils.new



  u.make_data_module
  # u.data
  # u.prefectures
end


