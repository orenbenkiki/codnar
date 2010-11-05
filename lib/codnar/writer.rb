module Codnar

  # Write chunks into a disk file.
  class Writer

    # Write one chunk or an array of chunks to a disk file.
    def self.write(path, data)
      self.new(path) do |writer|
        writer << data
      end
    end

    # Add one chunk or an array of chunks to the disk file.
    def <<(data)
      case data
      when Array
        @chunks += data
      when Hash
        @chunks << data
      else
        raise "Invalid data class: #{data.class}"
      end
    end

  protected

    # Write chunks into the specified disk file.
    def initialize(path, &block)
      @chunks = []
      File.open(path, "w") do |file|
        block.call(self)
        file.print(@chunks.to_yaml)
      end
    end

  end

end
