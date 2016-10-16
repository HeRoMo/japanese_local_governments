require __dir__+'/../data/data_converter.rb'
namespace :jlg do
  desc 'generate JLG::DATA module from xls file(download from http://www.soumu.go.jp/denshijiti/code.html)'
  task :convert, :xls_file_name do |task, args|
    filename = args[:xls_file_name]
    puts "次のファイルから JLG::DATA モジュールを生成します"
    puts filename
    conv = DataConverter.new(filename)

    conv.read_data
    conv.make_data_module
  end
end
