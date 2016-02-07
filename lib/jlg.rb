require "japanese_local_governments/version"
require 'japanese_local_governments/cli'

module JLG
  # 指定されたファイル、または標準出力に結果を出力する
  # @param filename [String] 出力先のファイル名。nilの場合は標準出力に出力する
  # @param sjis [Boolean] ファイル出力する場合にShiftJISで出力するかどうかを指定する
  # @yield [out] 結果を出力する処理を実装する
  # @yieldparam out [IO] 出力先のIOオブジェクト。
  def self.list(filename=nil, sjis:false)
    encode = sjis ? 'Shift_JIS':'UTF-8'
    out = filename.nil? ? $stdout : open(filename, "wb:#{encode}")
    yield(out)
  rescue =>e
    raise e
  ensure
    out.close if out.is_a? File
  end
end
