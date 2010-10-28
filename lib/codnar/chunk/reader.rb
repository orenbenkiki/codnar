# Read chunks from disk files.
class Codnar::Chunk::Reader

  # Load all chunks to memory.
  def initialize(paths)
    @chunks = {}
    paths.each do |path|
      chunks = YAML.load_file(path)
      load_file_chunks(chunks)
    end
  end

  # Load all chunks from a file into memory.
  def load_file_chunks(chunks)
    chunks.each do |chunk|
      @chunks[chunk.name] = chunk
    end
  end

  # Fetch a chunk by its name.
  def [](name)
    return @chunks[name] ||= Codnar::Chunk::Reader::fake_chunk(name)
  end

  # Return a fake chunk for the specified name.
  def self.fake_chunk(name)
    return {
      "name" => name,
      "locations" => [ { "file" => "MISSING", "line" => "NA" } ],
      "fragments" => [ { "lines" => 1, "kind" => "html", "content" => "<div class='missing'>MISSING</div>\n" } ],
    }
  end

end
