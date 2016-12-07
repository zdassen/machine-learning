# coding: utf-8
#
# default_dict.rb
#
class DefaultDict
  
  def initialize(dataset)
    @d = dataset
    @dd = Hash.new { |h, k| h[k] = 0 }
    dataset.each { |d| @dd[d] += 1 }
  end

  def to_s; @dd.to_s; end
  def keys; @dd.keys; end
  def values; @dd.values; end
  def n; @dd.values.inject :+; end

  alias :classes :keys
  alias :counts :values

  def [](klass); @dd[klass]; end
  def key?(k); @dd.key? k; end

end