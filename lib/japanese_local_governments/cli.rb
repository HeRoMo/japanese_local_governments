require 'jlg'
require 'thor'
require 'japanese_local_governments/governments'
require 'japanese_local_governments/prefectures'

module JLG
  class CLI < Thor
    desc "list","Output local governments by CSV format"
    method_option :prefectures, type: :boolean, aliases:'-p', required:false, desc: "output only prefecures"
    method_option :sjis, type: :boolean, aliases:'-s', required:false, desc: "output sjis encoding(file output only)"
    method_option :output, type: :string, aliases:'-o', required:false, desc: "output filepath"
    def list
      pref_only = options[:prefectures]
      if pref_only
        JLG::Prefectures.list(options[:output],sjis:options[:sjis])
      else
        JLG::Governments.list(options[:output],sjis:options[:sjis])
      end
    rescue =>e
      $stderr.puts e.message
    end

    desc "code PREF_NAME [NAME]", "Show code of pref, name"
    def code(pref, name=pref)
      code = JLG::Governments.code_of(pref, name)
      $stdout.puts code unless code.nil?
    end

    desc "data CODE", "Show local government data of code"
    def data(code)
      data = JLG::Governments.data_of(code.to_i)
      $stdout.puts data.values.join(',') unless data.nil?
    end

    desc "add_code INPUT_FILE", "Read CSV file, Output append local government code"
    method_option :output, type: :string, aliases:'-o', required:false, desc: 'output filepath'
    method_option :pref_column, type: :string, aliases:'-p', require:false, default:'pref',desc: 'set prefecure column name'
    method_option :name_column, type: :string, aliases:'-n', require:false, default:'name',desc: 'set name column name'
    method_option :sjis, type: :boolean, aliases:'-s', require:false, default:false, desc: 'input/output in sjis.(default: UTF-8)'
    def add_code(input_file)
      JLG::Governments.append_code(input_file, options[:output], pref:options[:pref_column], name:options[:name_column], sjis:options[:sjis])
    rescue =>e
      $stderr.puts e.message
    end

  end
end
