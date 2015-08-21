module FileUtil
  def self.read_three_parts(filename, begin_middle, begin_after)
    lines_before = []
    lines_middle = []
    lines_after = []
    File.open(filename, 'r') do |f|
      state = :BEFORE
      f.each_line do |line|
        case line.strip
          when begin_middle
            lines_before << line
            state = :MIDDLE
            next
          when begin_after
            lines_after << line
            state = :AFTER
            next
        end
        case state
          when :BEFORE
            lines_before << line
          when :MIDDLE
            lines_middle << line
          when :AFTER
            lines_after << line
        end
      end
    end
    
    return lines_middle, lines_before, lines_after
  end
end