module Codnar

  # Format chunks into HTML.
  class Formatter

  protected

    # Convert array of lines to array of line groups with the same line kind.
    def self.grouped_lines(lines)
      return lines.inject([]) { |groups, next_line| Formatter.group_next_line(groups, next_line) }
    end

    # Add the next line to the line groups.
    def self.group_next_line(groups, next_line)
      last_group = groups.last
      if last_group.andand.last.andand.kind == next_line.kind
        last_group.push(next_line)
      else
        groups.push([ next_line ])
      end
      return groups
    end

  end

end
