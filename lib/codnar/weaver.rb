module Codnar

  # Weave all chunks to a unified HTML.
  class Weaver < Reader

    # Load all chunks from the specified disk files to memory for weaving using
    # the specified templates.
    def initialize(errors, paths, templates)
      super(errors, paths)
      @templates = templates
    end

    # How to process each magical file template.
    FILE_TEMPLATE_PROCESSORS = {
      "file" => lambda { |name, data| data },
      "image" => lambda { |name, data| Weaver.embedded_base64_img_tag(name, data) },
    }

    # Weave the HTML for a named chunk.
    def weave(template, chunk_name = @root_chunk)
      return process_file_template(template, chunk_name) if FILE_TEMPLATE_PROCESSORS.include?(template)
      @last_chunk = chunk = self[chunk_name.to_id]
      expand_chunk_html(chunk)
      return process_template(chunk, template)
    end

  protected

    # Due to http://github.com/relevance/rcov/issues/#issue/43 the following regular expressions must be on a single line.

    # Detect embedded chunks (+type+ before +src+).
    TYPE_SRC_CHUNK = / [ ]* <embed \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s+ src = ['\"] \#* (.*?) ['\"] \s* (?: \/> | > \s* <\/embed> ) [ ]* /x

    # Detect embedded chunks (+src+ before +type+).
    SRC_TYPE_CHUNK = / [ ]* <embed \s+ src = ['\"] \#* (.*?) ['\"] \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s* (?: \/> | > \s* <\/embed> ) [ ]* /x

    # Recursively expand all embedded chunks inside a container chunk.
    def expand_chunk_html(chunk)
      html = chunk.html
      @errors.push("No HTML in chunk: #{chunk.name} #{Weaver.locations_message(chunk)}") unless html
      #! TRICKY: All "container" chunks are assumed to be whole-file chunks with
      #! a single location. Which makes sense as these are documentation and not
      #! code chunks. TODO: It would be nice to know the exact line number of
      #! the chunk embedding directive for better pinpointing of any error.
      @errors.in_path(chunk.locations[0].file) do
        chunk.expanded_html ||= expand_embedded_chunks(html || "").chomp
      end
    end

    # Recursively expand_embedded_chunks all embedded chunk inside an HTML.
    def expand_embedded_chunks(html)
      return html.gsub(TYPE_SRC_CHUNK) { |match| weave($1, $2).chomp } \
                 .gsub(SRC_TYPE_CHUNK) { |match| weave($2, $1).chomp }
    end

    # Process the chunk using an ERB template prior to inclusion in container
    # chunk.
    def process_template(chunk, template_name)
      template_text = @templates[template_name] ||= (
        @errors << "Missing ERB template: #{template_name}"
        "<%= chunk.expanded_html %>\n"
      )
      return (
        (
          chunk.erb ||= {}
        )[template_name] ||= ERB.new(template_text, nil, "%")
      ).result(binding)
    end

    # {{{ Processing the file template

    # Process one of the magical file templates. The content of the file,
    # optionally processed, is directly embedded into the generated
    # documentation. If the file's path begins with ".", it is taken to be
    # relative to the current working directory. Otherwise, it is searched for
    # in Ruby's load path, allowing easy access to files packaged inside gems.
    def process_file_template(template, path)
      begin
        path = DataFiles.expand_path(path) unless path[0,1] == "."
        return FILE_TEMPLATE_PROCESSORS[template].call(path, File.read(path))
      rescue Exception => exception
        @errors.push("#{$0}: Reading file: #{path} exception: #{exception} #{Reader.locations_message(@last_chunk)}") \
          if @last_chunk
        return "FILE: #{path} EXCEPTION: #{exception}"
      end
    end

    # }}}

    # {{{ Processing Base64 embedded data images

    # Create an +img+ tag with an embedded data URL. Different browsers have
    # different constraints about the size of the resulting URL, so YMMV.
    def self.embedded_base64_img_tag(name, data)
      extension = File.extname(name).sub(".", "/")
      return "<img src='data:image#{extension};base64," \
           + Base64.encode64(data) \
           + "'/>"
    end

    # }}}

  end

end
