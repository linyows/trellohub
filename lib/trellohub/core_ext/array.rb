class Array
  def print_with_vertical_line(title: nil, header: true)
    max = self.max_lengths

    self.each.with_index(1) do |line, index|
      puts "[#{title}]" if title && index == 1

      if header && index == 2
        column = self.first.count
        puts column.times.map.with_index { |i|
          ''.ljust(max[i], '-') }.
          join(' | ')
      end

      puts line.map.with_index { |word, i|
        "#{word}".ljust(max[i]) }.
        join(' | ')
    end
  end
  alias_method :puts_with_vl, :print_with_vertical_line

  def max_lengths
    self.each_with_object([]) do |line, obj|
      line.each.with_index do |v, i|
        length = v.to_s.width
        obj[i] = length if obj[i].nil? || obj[i] < length
      end
    end
  end
end
