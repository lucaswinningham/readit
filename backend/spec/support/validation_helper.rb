module Helpers
  module ValidationHelper
    def blank_values
      ['', ' ', "\n", "\r", "\t", "\f"]
    end
  end
end
