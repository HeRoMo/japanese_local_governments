require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jlg'
require 'csv'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

DATA_FILE =  File.expand_path('../../data/japanese_local_governments.csv', __FILE__)
def read_data(filename=DATA_FILE, columns:['code','pref','name','type','district','furigana'],sjis:false)
  encode = (sjis) ? 'Shift_JIS':'UTF-8'
  out = StringIO.new
  CSV.foreach(filename,encoding:"#{encode}:UTF-8",headers: true,return_headers: true).each do |line|
    out.puts line.to_h.select{|k,v| columns.include? k}.values.join(',')
  end
  out.string
end
