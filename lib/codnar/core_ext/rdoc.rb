# Expand RDoc text with some Codnar extensions.
module RDoc

  # Process a RDoc String and return the resulting HTML.
  def self.to_html(rdoc)
    return ::RDoc::Markup::ToHtml.new.convert(rdoc)
  end

end
