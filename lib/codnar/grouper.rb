module Codnar

  # Group classified lines according to kind.
  module Grouper

    # Convert array of classified lines to array of classified line groups with
    # the same line kind.
    def self.lines_to_groups(lines)
      return lines.reduce([], &method(:group_next_line))
    end

  protected

    # Add the next classified line to the classified line groups.
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
