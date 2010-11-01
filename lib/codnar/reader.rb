module Codnar

  # Read chunks from disk files.
  class Reader

    # Load all chunks to memory.
    def initialize(errors, paths)
      @errors = errors
      @chunks = {}
      paths.each do |path|
        load_path_chunks(path)
      end
    end

    # Fetch a chunk by its name.
    def [](name)
      return @chunks[name.to_id] ||= (
        @errors << "Missing chunk: #{name}"
        Reader::fake_chunk(name)
      )
    end

  protected

    # Load all chunks from a file into memory.
    def load_path_chunks(path)
      @errors.in_path(path) do
        chunks = YAML::load_file(path)
        merge_loaded_chunks(chunks)
      end
    end

    # Merge an array of chunks into memory.
    def merge_loaded_chunks(chunks)
      chunks.each do |new_chunk|
        old_chunk = @chunks[id = new_chunk.name.to_id]
        if old_chunk.nil?
          @chunks[id] = new_chunk
        elsif Reader::same_chunk?(old_chunk, new_chunk)
          old_chunk.locations += new_chunk.locations
        else
          @errors.push(Reader.different_chunks_error(old_chunk, new_chunk))
        end
      end
    end

    # Check whether two chunks contain the same "stuff".
    def self.same_chunk?(old_chunk, new_chunk)
      return Reader::chunk_payload(old_chunk) == Reader::chunk_payload(new_chunk)
    end

    # Return just the actual payload of a chunk for equality comparison.
    def self.chunk_payload(chunk)
      return chunk.reject { |key, value| key == "locations" || key == "name" }
    end

    # Error message when two different chunks have the same name.
    def self.different_chunks_error(old_chunk, new_chunk)
      old_location = Reader::locations_message(old_chunk)
      new_location = Reader::locations_message(new_chunk)
      return "Chunk: #{old_chunk.name} is different #{new_location}, and #{old_location}"
    end

    # Format a chunk's location for an error message.
    def self.locations_message(chunk)
      locations = chunk.locations.map { |location| "in file: #{location.file} at line: #{location.line}" }
      return locations.join(" or ")
    end

    # Return a fake chunk for the specified name.
    def self.fake_chunk(name)
      return {
        "name" => name,
        "locations" => [ { "file" => "MISSING" } ],
        "html" => "<div class='missing'>MISSING</div>\n"
      }
    end

  end

end
