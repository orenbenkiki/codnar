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
    def weave(chunk_name, template)
      chunk = self[chunk_name.to_id]
      expand_chunk_html(chunk)
      process_template(chunk, template)
    end

  protected

    # Due to http://github.com/relevance/rcov/issues/#issue/43 the following regular expressions must be on a single line.

    # Detect embedded chunks (type= before src=).
    TYPE_SRC_CHUNK = / [ ]* <script \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s+ src = ['\"] \#* (.*?) ['\"] \s* (?: \/> | > \s* <\/script> ) [ ]* /x

    # Detect embedded chunks (src= before type=).
    SRC_TYPE_CHUNK = / [ ]* <script \s+ src = ['\"] \#* (.*?) ['\"] \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s* (?: \/> | > \s* <\/script> ) [ ]* /x

    # Recursively expand all embedded chunks inside a container chunk.
    def expand_chunk_html(chunk)
      html = chunk.html
      @errors.push("No HTML in chunk: #{chunk.name} #{Weaver.locations_message(chunk)}") unless html
      # TRICKY: All "container" chunks are assumed to be whole-file chunks with
      # a single location. Which makes sense as these are documentation and not
      # code chunks. TODO: It would be nice to know the exact line number of
      # the chunk embedding directive for better pinpointing of any error.
      @errors.in_path(chunk.locations[0].file) do
        chunk.expanded_html ||= expand_embedded_chunks(html || "").chomp
      end
    end

    # Recursively expand_embedded_chunks all embedded chunk inside an HTML.
    def expand_embedded_chunks(html)
      return html.gsub(TYPE_SRC_CHUNK) { |match| weave($2, $1).chomp } \
                 .gsub(SRC_TYPE_CHUNK) { |match| weave($1, $2).chomp }
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

  end

end
