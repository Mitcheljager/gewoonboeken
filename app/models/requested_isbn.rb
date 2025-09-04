class RequestedISBN < ApplicationRecord
  enum :status, [:not_found, :error, :rejected, :resolved]
end
