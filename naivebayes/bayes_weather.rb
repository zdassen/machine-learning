# coding: utf-8
#
# bayes_weather.rb
#
# ※最尤推定法をブログにまとめる
# ※それをgist→はてブに載せる
require "./lib/default_dict.rb"
require "./lib/read_data.rb"


# ※ラベルデータ用であることを明記する
class NaiveBayes

  def initialize(dataset)
    @d = dataset
    @dd = DefaultDict.new @d.map { |r| r.last }
  end
  
  # 事前確率を求める
  # @param [String] klass クラス値
  def pri(klass)
    # dd = DefaultDict.new @d.map { |r| r.last }
    # if dd.key? klass then dd[klass].to_f / dd.n else 0 end
    if @dd.key? klass then @dd[klass].to_f / @dd.n else 0 end
  end

  # 事前条件を含むデータをピックアップする
  # @param [String] klass クラス値
  def pickup(klass)
    @d.select { |r| r.last == klass }
  end

  # 尤度を求める(=likelihood)
  # @param [String] f 特徴値
  # @param [Integer] i 特徴インデックス
  # @param [String] klass クラス値
  def lhd(f, i, klass)
    a = pickup klass

    # P(feature | klass)
    na = a.length
    nb = a.count { |r| r[i] == f }
    if nb > 0 then nb.to_f / na else 0 end
  end

  # 事前確率を尤度で更新する
  # @param [Array] sample サンプルデータ(クラス値除く)
  # @param [String] klass クラス値
  def updates(sample, klass)

    # P(klass) * ΠP(sample x | klass)
    sample.each.with_index.inject(1) do |prob, (f, i)|
      prob * lhd(f, i, klass)
    end
  end

  # 事後確率を求める (= P(klass | sample x))
  # @param [String] klass クラス値
  # @param [Array] sample サンプルデータ(クラス値除く)
  def post(klass, sample)
    klasses = @dd.keys
    
    # each P(sample x | klass) * P(klass)
    pxs = {}
    klasses.each { |k| pxs[k] = updates(sample, k) * pri(k) }

    # P(sample x) = ΣP(sample x | klass) * P(klass)
    px = pxs.values.inject(0) { |prev, prob| prev + prob }

     begin
       pxs[klass].to_f / px
     rescue ZeroDivisionError
       0
     end
  end

  # サンプルデータから事後確率が最大となる
  # 結果(クラス値を)返す
  # @param [Array] sample サンプルデータ(クラス値除く)
  def predict(sample)
    @dd.keys.max_by { |k| post k, sample }
  end

  # サンプルデータからの予測結果を表示する
  # @param [Array] sample サンプルデータ(クラス値除く)
  def table(sample)
    ksize = @dd.keys.map { |k| k.length }.max
    @dd.keys.each do |k|
      puts "%s | %s" % [pads(k, ksize), post(k, sample)]
    end
  end

  private

    # 空白を追加して文字列をn文字に揃える
    # @param [String] s 文字列
    # @param [Integer] n 空白追加後の文字列長
    def pads(s, n)
      gap = n - s.length
      if n > 0 then " " * gap + s else s end
    end

end

# ※テスト
# データを読み込む
# ※教師(クラス)データは末尾列に記録されているとする
dataset = read_data "./data/weather.txt"

# ※テスト
=begin
d = DefaultDict.new c
puts d
puts d.keys.inspect
puts d.values.inspect
puts d.n
puts d["yes"]
puts d["middle"]
puts d["no"]
=end

# ※テスト2
=begin
d2 = DefaultDict.new [1, 2, 3, 1, 1, 2, 1, 1, 1, 2, 1, 2]
puts d2
puts d2.keys
puts d2.values
puts d2.classes.inspect
puts d2.counts.inspect
=end

# 事前確率(※これでよい?)
# ※結果のみ(天候のデータを得ていない状態での確率分布)
# sample = ["sunny", "hot", "high", "FALSE"]
# nb = NaiveBayes.new dataset
=begin
puts nb.pri "yes"
puts nb.pri "no-ans"
puts nb.pri "no"
=end

# pickupテスト
# ["yes", "no-ans", "no"].each do |k|
#   nb.pickup(k).each { |r| puts r.inspect }
# end

# lhdテスト
# ※m推定を行わなければ?これで正しい
=begin
puts nb.lhd("sunny", 0, "yes")
puts nb.lhd("hot", 1, "yes")
puts nb.lhd("high", 2, "yes")
puts nb.lhd("FALSE", 3, "yes")
=end

# ※updatesテスト
=begin
puts nb.updates(sample, "yes")
puts nb.updates(sample, "no")
=end

# ※postテスト
=begin
puts nb.post("yes", sample)
puts nb.post("no", sample)
puts ["yes", "no"].inject(0) { |sum, k| sum + nb.post(k, sample) }
=end

# ※predictテスト
# puts nb.predict(sample)

# ※tableテスト
# nb.table sample