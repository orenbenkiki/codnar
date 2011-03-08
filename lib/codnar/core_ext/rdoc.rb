# Expand RDoc text with some Codnar extensions.
module RDoc

  # Process a RDoc String and return the resulting HTML.
  def self.to_html(rdoc)
    html = ::RDoc::Markup::ToHtml.new.convert(rdoc)
    return html.gsub(/\n*<p>\n*/, "\n<p>\n") \
               .gsub(/\n*<\/p>\n*/, "\n</p>\n") \
               .gsub(/\n*<pre>\n*/, "\n<pre>\n") \
               .gsub(/\n*<\/pre>\n*/, "\n</pre>\n") \
               .sub(/^\n*/, "")
  end

end
