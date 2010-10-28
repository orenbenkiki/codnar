require "rdiscount"
require "yaml"

# This module contains all the code narrator code.
module Codnar
end

require "codnar/core_ext/hash"
require "codnar/core_ext/string"

require "codnar/errors"
require "codnar/version"

require "codnar/chunk"
require "codnar/chunk/reader"
require "codnar/chunk/writer"

require "codnar/markdown"
