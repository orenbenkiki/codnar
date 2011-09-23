module Codnar

  # Convert Markdown to HTML.
  module Markdown

    # Process a Markdown String and return the resulting HTML. In addition to the
    # normal Markdown syntax, processing supports the following Codnar-specific
    # extensions:
    #
    # * The notation "[[chunk|template]]" is expanded to embedding the specified
    #   chunk (name) using the specified template at Weave time.
    # * The notation "[[#name]]" defines an empty anchor. The HTML anchor id is
    #   not the specified name, but rather the identifier generated from it (in
    #   the same way that chunk names are converted to identifiers).
    # * The notation "[...](#name)" defines a link to an anchor, which is either
    #   the chunk with the specified name, or an empty anchor defined as above.
    def self.to_html(markdown)
      markdown = embed_chunks(markdown)
      markdown = id_anchors(markdown)
      html = RDiscount.new(markdown).to_html
      html = id_links(html)
      return html.clean_markup_html
    end

  protected

    # Expand "[[chunk|template]]" to HTML embed tags. Use identifiers instead of
    # names in the +src+ field for safety, unless the template is a magical file
    # template, in which case we must preserve the file path.
    def self.embed_chunks(markdown)
      return markdown.gsub(/\[\[(.*?)\|(.*?)\]\]/) do
        src = $1
        template = $2
        src = src.to_id unless Codnar::Weaver::FILE_TEMPLATE_PROCESSORS.include?(template)
        "<embed src='#{src}' type='x-codnar/#{template}'/>"
      end
    end

    # Expand "[[#name]]" anchors to HTML anchor tags with the matching identifier.
    def self.id_anchors(markdown)
      return markdown.gsub(/\[\[#(.*?)\]\]/) { "<a id='#{$1.to_id}'/>" }
    end

    # Expand "href='#name'" links to the matching "href='#id'" links.
    def self.id_links(html)
      return html.gsub(/href=(["'])#(.*?)(["'])/) { "href=#{$1}##{$2.to_id}#{$3}" }
    end

  end

end
