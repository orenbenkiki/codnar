require "rake"
require "rake/tasklib"

require "codnar"
require "codnar/rake/split_task"
require "codnar/rake/weave_task"

module Codnar

  # This module contains all the Codnar Rake tasks code.
  module Rake

    class << self

      # The root folder to store all chunk files under.
      attr_accessor :chunks_dir

      # The list of split chunk files for later weaving.
      attr_accessor :chunk_files

    end

    Rake.chunk_files = []
    Rake.chunks_dir = "chunks"

    # Compute options for invoking an application.
    def self.application_options(output, configurations)
      options = [ "-o", output ]
      options += [ "-c" ] \
               + configurations.map { |configuration| configuration.to_s } \
               + [ "--" ] \
        if configurations.size > 0
      return options
    end

    # Return the list of actual configuration files (as opposed to names of
    # built-in configurations) for use as dependencies.
    def self.configuration_files(configurations)
      return configurations.find_all { |configuration| File.exists?(configuration.to_s) }
    end

  end

end
