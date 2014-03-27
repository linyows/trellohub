class Array
  def max_lengths
    self.each_with_object([]) do |line, obj|
      line.each.with_index do |v, i|
        length = v.to_s.width
        obj[i] = length if obj[i].nil? || obj[i] < length
      end
    end
  end
end
