module Codnar

  # Cache long computations in disk files.
  class Cache

    # Whether to recompute values even if they are cached.
    attr_accessor :force_recompute
  
    # Connect to an existing disk cache. The cache is expected to be stored in
    # a directory of the specified name, which is either in the current working
    # directory or in one of its parent directories.
    def initialize(directory, &block)
      @force_recompute = false
      @computation = block
      @directory = find_directory(Dir.pwd, directory)
      if @directory
        class <<self; alias [] :cached_computation; end
      else
        class <<self; alias [] :uncached_computation; end
        $stderr.puts("#{$0}: Could not find cache directory: #{directory}.")
      end
    end

    # Access the results of the computation for the specified input. Fetch the
    # result from the cache if it is there, otherwise invoke the computation
    # and store the result in the cache for the next time.
    def cached_computation(input)
      file = cache_file(input)
      return YAML.load_file(file) if File.exists?(file) and not @force_recompute
      result = @computation.call(input)
      File.open(file, "w") { |file| file.write(result.to_yaml) }
      return result
    end

    # Return the file expected to cache the computed results for a given input,
    def cache_file(input)
      key = Digest.hexencode(Digest::SHA2.digest(input.to_yaml))
      return @directory + "/" + key + ".yaml"
    end

    # Access the results of a computation for the specified input, in case we
    # do not have a cache directory to look for and store the results in.
    def uncached_computation(input)
      return @computation.call(input)
    end

  protected

    # Find the path of the cache directory, search from the given working
    # directory upward until finding a match.
    def find_directory(working_directory, cache_directory)
      directory = working_directory + "/" + cache_directory
      return directory if File.exists?(directory)
      parent_directory = File.dirname(working_directory)
      return nil if parent_directory == working_directory
      return find_directory(parent_directory, cache_directory)
    end

  end

end
