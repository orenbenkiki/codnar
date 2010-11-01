module Codnar

  # Weave all chunks to a unified HTML.
  class Weaver < Reader

    # Weave the HTML for a named chunk.
    def weave(chunk_name)
      chunk_data = self[chunk_name.to_id]
      chunk_html = chunk_data["html"]
      @errors.push("No HTML in chunk: #{chunk_data["name"]} #{Weaver::locations_message(chunk_data)}") unless chunk_html
      return expand_embedded_chunks(chunk_html || "")
    end

  protected

    # Due to http://github.com/relevance/rcov/issues/#issue/43 the following regular expressions must be on a single line.

    # Detect embedded chunks (type= before src=).
    TYPE_SRC_CHUNK = / [ ]* <script \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s+ src = ['\"] \#* (.*?) ['\"] \s* (?: \/> | > \s* <\/script> ) [ ]* [\r]? [\n]? /x

    # Detect embedded chunks (src= before type=).
    SRC_TYPE_CHUNK = / [ ]* <script \s+ src = ['\"] \#* (.*?) ['\"] \s+ type = ['\"] x-codnar\/ (.*?) ['\"] \s* (?: \/> | > \s* <\/script> ) [ ]* [\r]? [\n]? /x

    # Recursively expand all embedded chunks in an HTML.
    def expand_embedded_chunks(html)
      return html.gsub(TYPE_SRC_CHUNK) { |match| weave($2) } \
                 .gsub(SRC_TYPE_CHUNK) { |match| weave($1) }
    end

  end

end
