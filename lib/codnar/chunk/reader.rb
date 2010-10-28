# Read chunks from disk files.
class Codnar::Chunk::Reader

  # Load all chunks to memory.
  def initialize(errors, paths)
    @errors = errors
    @chunks = {}
    paths.each do |path|
      load_path_chunks(path)
    end
  end

  # Load all chunks from a file into memory.
  def load_path_chunks(path)
    @errors.in_path(path) do
      chunks = YAML.load_file(path)
      merge_loaded_chunks(chunks)
    end
  end

  # Merge an array of chunks into memory.
  def merge_loaded_chunks(chunks)
    chunks.each do |chunk|
      @chunks[chunk.name] = chunk
    end
  end

  # Fetch a chunk by its name.
  def [](name)
    return @chunks[name] ||= fake_chunk(name)
  end

  # Return a fake chunk for the specified name.
  def fake_chunk(name)
    @errors << "Missing chunk: #{name}"
    return {
      "name" => name,
      "locations" => [ { "file" => "MISSING", "line" => "NA" } ],
      "fragments" => [ { "lines" => 1, "kind" => "html", "content" => "<div class='missing'>MISSING</div>\n" } ],
    }
  end

end
