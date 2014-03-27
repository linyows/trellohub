require 'rainbow/ext/string'

class String
  def width
    self.no_coloring.each_char.map { |one_letter|
      one_letter.ascii_only? ? 1 : 2
    }.inject(:+) || 0
  end

  def no_coloring
    self.gsub(/\e\[\d?\d?;?\d\d?m/, '').gsub(/\e\[0m/, '')
  end

  def constantize
    Object.const_get(self)
  end

  def ljust_with_multibyte(length, padstr = ' ')
    length > self.width ? "#{self}#{padstr * (length - self.width)}" : self
  end
  alias_method :ljust, :ljust_with_multibyte
end
