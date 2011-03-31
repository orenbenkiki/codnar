module Codnar

  # Weave all chunks to a unified HTML.
  class Weaver < Reader

    # Load all chunks from the specified disk files to memory for weaving using
    # the specified templates.
    def initialize(errors, paths, templates)
      super(errors, paths)
      @templates = templates
    end

    # Weave the HTML for a named chunk.
    def weave(template, chunk_name = @root_chunk)
      return process_file(chunk_name) if template == "file"
      @last_chunk = chunk = self[chunk_name.to_id]
      expand_chunk_html(chunk)
      return process_template(chunk, template)
    end

  protected

    # Due to http://github.com/relevance/rcov/issues/#issue/43 the following regular expressions must be on a single line.

    # Detect embedded chunks (type= before src=).
    TYPE_SRC_CHUNK = / [ ]* <embed \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s+ src = ['\"] \#* (.*?) ['\"] \s* (?: \/> | > \s* <\/embed> ) [ ]* /x

    # Detect embedded chunks (src= before type=).
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

    # Process a disk file (invoked by the special "file" template).
    def process_file(path)
      begin
        return File.read(path)
      rescue Exception => exception
        @errors.push("#{$0}: Reading file: #{path} exception: #{exception} #{Reader.locations_message(@last_chunk)}") if @last_chunk
        return "FILE: #{path} EXCEPTION: #{exception}"
      end
    end

  end

end
