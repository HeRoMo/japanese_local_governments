# JapaneseLocalGovernments

[![Build Status](https://travis-ci.org/HeRoMo/japanese_local_governments.svg?branch=master)](https://travis-ci.org/HeRoMo/japanese_local_governments)

これは日本の地方自治体情報を扱うためのユーティリティツールです。

自治体から提供されるオープンデータは増えつつある状況ですが、それらのデータにはコードが付与されないことが多く、
様々なデータを接続して利用するするのに手間がかかります。

このツールでは、各地方自治体のコードを調べたり、コードに対応する自治体の情報を得ることができます。
また、都道府県、自治体名のあるCSVファイルにコードを付加することもできます。

これらの機能をライブラリとして提供するとともに、コマンドラインツールとしても利用できます。

次のコマンドで本ツールの持つ地方自治体のデータがすべて出力されます。

    $ jlg list

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'japanese_local_governments'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install japanese_local_governments

## Usage

この gem をインストールすると jlg というコマンドラインツールがインストールされます。

jlg は次のサブコマンドを持ちます。

- code
- data
- list
- add_code
- help

### code
都道府県名、自治体名をスペース区切りで指定して、その自治体のコードを出力します。
都道府県のコードを得たい場合には都道府県のみを指定します。
都道府県以下の自治体のコードを得る場合には 都道府県名 と 自治体名 を指定します。
政令指定都市 の行政区のコードを得る場合には 自治体名は市名から始めてください。

#### 使用例
    $ jlg code 大阪府
    270008
    
    $jlg code 大阪府 大阪市
    271004
    
    $jlg code 大阪府 大阪市天王寺区
    271098

### data
自治体コードを指定してその自治体の情報を出力します。
出力される情報は コード,都道府県名,自治体名,種別,地方,ふりがな で、カンマ区切りで出力します。
指定するコードはゼロパティングしてもしなくても構いません。

#### 使用例
    $ jlg data 10006
    010006,北海道,北海道,都道府県,北海道地方,ほっかいどう
    
    $jlg data 011002
    011002,北海道,札幌市,政令市,北海道地方,さっぽろし

### list
自治体データのリストを出力します。
`jlg list` を実行すると、本ツールが持つ全てのデータを標準出力に出力します。
出力する文字エンコーディングは UTF-8です。

`-o` オプションを利用すると、指定したファイルに結果を出力します。
`-p` オプションを利用すると、都道府県のみのデータを出力します。
`-s` オプションを利用すると ShiftJISでファイルを出力します。(`-o` オプションと同時に使った場合のみ有効)

#### 使用例
    $ jlg list
    code,pref,name,type,district,furigana
    010006,北海道,北海道,都道府県,北海道地方,ほっかいどう
    011002,北海道,札幌市,政令市,北海道地方,さっぽろし
    011011,北海道,札幌市中央区,行政区,北海道地方,さっぽろしちゅうおうく
    011029,北海道,札幌市北区,行政区,北海道地方,さっぽろしきたく
    011037,北海道,札幌市東区,行政区,北海道地方,さっぽろしひがしく
    011045,北海道,札幌市白石区,行政区,北海道地方,さっぽろししろいしく
    ...以下省略
    
    $ jig list -p -o 都道府県リスト.csv #=> 都道府県のデータを ファイル '都道府県リスト.csv' に出力する
    

### add_code
都道府県名、自治体名を表すカラムを持つCSVファイルに 自治体コードをカラムを追加します。
入力ファイルとしては次のようなファイルを用意します。 
1行目はカラムヘッダである必要があります。デフォルトでは pref を都道府県名を表すカラム、name を自治体名を表すカラムとして処理します。

    pref,name,type,district,furigana
    北海道,北海道,都道府県,北海道地方,ほっかいどう
    北海道,札幌市,政令市,北海道地方,さっぽろし
    北海道,札幌市中央区,行政区,北海道地方,さっぽろしちゅうおうく
    北海道,札幌市北区,行政区,北海道地方,さっぽろしきたく

上記のようなCSVファイルは次のようなファイルに返還されます。

    code,pref,name,type,district,furigana
    010006,北海道,北海道,都道府県,北海道地方,ほっかいどう
    011002,北海道,札幌市,政令市,北海道地方,さっぽろし
    011011,北海道,札幌市中央区,行政区,北海道地方,さっぽろしちゅうおうく
    011029,北海道,札幌市北区,行政区,北海道地方,さっぽろしきたく

`-o` オプションを利用すると、出力ファイル名を指定することができます。このオプションがない場合、入力ファイル名に実行日付が付加されたファイル名で出力します。
`-p`,`-n` オプションを利用すると都道府県名と自治体名を表すカラム名を指定することができます。
`-s` オプションを利用するとShiftJISで作成されたCSVファイルを処理できます。
#### 使用例
    $ jlg add_code 自治体データ.csv  #=> 自治体データ_20160207.csv という名前のファイルに出力される
    
    $ jlg add_code 自治体データ.csv -o 自治体データ_コード付き.csv #=> 自治体データ_コード付き.csv という名前のファイルに出力される
    
    $ jlg add_code 自治体データ.csv -o 自治体データ_コード付き.csv -p 都道府県 -n 自治体名 #=> 自治体データ_コード付き.csv という名前のファイルに出力される。都道府県、自治体名のカラム名を指定しています。

    $ jlg add_code 自治体データ_sjis.csv -s #=> ShiftJISで作成されたCSVファイル 自治体データ_sjis.csv を読み込んで ShiftJIS で出力します。
  
### help
    $ jlg help [COMMAND]         # Describe available commands or one specific command
  

### データについて
本ライブラリで利用しているデータは次のサイドで配布されている情報を基にしています。
 
 [総務省｜電子自治体｜全国地方公共団体コード](http://www.soumu.go.jp/denshijiti/code.html)

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment. 
Run `bundle exec jlg` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, 
and then run `bundle exec rake release`, which will create a git tag for the version, 
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HeRoMo/japanese_local_governments.

