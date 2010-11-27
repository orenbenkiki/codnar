module Codnar

  # Write temporary files.
  module WithTempfile

  protected

    def write_tempfile(path, content)
      file = Tempfile.open(path)
      file.write(content)
      file.close(false)
      return file.path
    end

  end

end
