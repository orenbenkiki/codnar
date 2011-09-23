module Codnar

  # Convert RDoc to HTML.
  module RDoc

    # Process a RDoc String and return the resulting HTML.
    def self.to_html(rdoc)
      return ::RDoc::Markup::ToHtml.new.convert(rdoc).clean_markup_html
    end

  end

end
