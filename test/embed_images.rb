require "codnar"
require "test/spec"

module Codnar

  # Test computing embedded image HTML tags.
  class TestEmbedImages < Test::Unit::TestCase

    def test_embed_image
      Weaver.embedded_base64_img_tag('fake file.png', 'fake file content').should \
        == "<img src='data:image/png;base64,ZmFrZSBmaWxlIGNvbnRlbnQ=\n'/>"
    end

  end

end
