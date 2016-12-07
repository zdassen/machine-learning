# coding: utf-8
#
# read_data.rb
#
# データを読み込む
# @param [String] path データファイルのパス
def read_data(path)
  if File.exist? path
    records = File.readlines path
    records.map { |r| r.chomp.split "," }    # 改行を取り除く&分割
  end
end