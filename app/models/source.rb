class Source < ApplicationRecord
  has_many :sources, dependent: :destroy

  has_one_attached :logo do |attachable|
    attachable.variant(:medium, resize_to_fill: [64, 64], quality: 75, format: :webp, preprocessed: true)
  end

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: { case_sensitive: false }
  validates :base_url, presence: true
  validates :shipping_cost_currency, inclusion: { in: VALID_CURRENCIES, message: "%{value} is not a valid currency" }

  # Update file name of logo to slug + extension before saving.
  # This is mostly to prevent rogue file names from being left in accidentally.
  before_save do
    if logo.attached?
        ext = "." + logo.blob.filename.extension
        logo.blob.update(filename: slug + ext)
    end
  end

  def to_param
    slug
  end
end
