# Write chunks into a disk file.
class Codnar::Chunk::Writer

  # Write chunks into the specified file.
  def initialize(path, &block)
    @chunks = []
    File.open(path, "w") do |file|
      block.call(self)
      file.print(@chunks.to_yaml)
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

end
