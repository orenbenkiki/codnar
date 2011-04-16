module Codnar

  # Provide access to data files packaged with the gem.
  module DataFiles

    # Given the name of a data file packaged in some gem, return the absolute
    # disk path for accessing that data file. This is similar to what +require+
    # does internally, but here we just want the path for reading data, rather
    # than load the Ruby code in the file.
    def self.expand_path(relative_path)
      $LOAD_PATH.each do |load_directory|
        absolute_path = File.expand_path(load_directory + "/" + relative_path)
        return absolute_path if File.exist?(absolute_path)
      end
      return relative_path # This will cause "file not found error" down the line.
    end

  end

end
