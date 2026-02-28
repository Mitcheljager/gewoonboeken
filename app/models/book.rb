class Book < ApplicationRecord
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  if ENV["BONSAI_URL"]
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: 1 }
  end

  has_many :listings, dependent: :destroy
  has_many :book_authors, dependent: :destroy
  has_many :authors, through: :book_authors
  has_many :book_genres, dependent: :destroy
  has_many :genres, through: :book_genres

  has_one_attached :cover_image do |attachable|
    attachable.variant(:large, resize_to_limit: [300, 500], quality: 80, format: :webp, preprocessed: true)
    attachable.variant(:small, resize_to_limit: [250, 190], quality: 80, format: :webp, preprocessed: true)
  end

  enum :format, [:unknown, :paperback, :hardcover], suffix: true
  enum :language, { dutch: "nl", english: "en" }

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A\d{13}\z/ }
  validates :format, inclusion: { in: Book.formats.keys }
  validates :language, inclusion: { in: Book.languages.keys }, allow_nil: true
  validates :published_date_text, format: { with: /\A[0-9\-]+\z/ }, allow_nil: true, allow_blank: true

  accepts_nested_attributes_for :book_authors, allow_destroy: true
  accepts_nested_attributes_for :book_genres, allow_destroy: true

  after_commit :cache_cover_urls, on: [:update], if: -> { cover_image.attached? }

  def to_param
    "#{title.parameterize}-#{isbn}"
  end

  def self.overview_join
    self.includes(:authors).references(:authors)
  end

  def self.full_join
    self.includes(:authors, listings: :source, cover_image_attachment: [:blob, { blob: :variant_records }])
        .references(:authors, :listings, :source)
  end

  def listings_with_price
    if listings.loaded?
      listings.select { |l| l.price.present? && l.price != 0 && l.available? }
    else
      listings.includes(:source).where.not(price: 0).where(available: true)
    end
  end

  def listings_with_price_sorted
    listings_with_price.sort_by { |listing| [listing.price, listing.shipping_cost_actual, listing.source.name] }
  end

  def lowest_price
    listings_with_price.map(&:price).compact.min
  end

  def cheapest_listing
    listings_with_price.min_by(&:price)
  end

  def authors_human_list
    human_list(authors.pluck(:name))
  end

  def requires_scrape?
    return true if last_scrape_started_at.nil?
    return true if is_scrape_frozen?
    return false if is_scrape_ongoing?

    last_scrape_finished_at.present? && last_scrape_finished_at < 1.day.ago
  end

  def is_scrape_ongoing?
    return false if last_scrape_started_at.nil?
    return false if is_scrape_frozen?

    return true if last_scrape_started_at.present? && last_scrape_finished_at.nil?

    last_scrape_finished_at < last_scrape_started_at
  end

  # If the start_at date is more than 10 minutes ago and the finished_at date has not yet been updated, the run probably
  # froze and we should re-run it to prevent it from getting stuck eternally.
  def is_scrape_frozen?
    last_scrape_started_at < 10.minutes.ago && (last_scrape_finished_at.nil? || last_scrape_finished_at < last_scrape_started_at)
  end

  def should_show_scrape_message?
    # !Temporary
    return false

    (requires_scrape? || is_scrape_ongoing?) &&
    # Only show message if book has never been scraped or last scrape is more than 2 days ago.
    # A scrape might still happen if it's earlier (see requires_scrape?), but we won't show a message or update the page.
    (last_scrape_finished_at.nil? || (last_scrape_finished_at.present? && last_scrape_finished_at < 2.days.ago))
  end

  # Returns a - if no number of pages are given, otherwise return a number with "." for the thousands delimiter,
  # as that is what is used in Dutch rather than commas.
  def formatted_number_of_pages
    self.number_of_pages.zero? ? "-" : number_with_delimiter(self.number_of_pages, delimiter: ".")
  end

  # The published_date_text is nothing but a string, but it only allows numbers and dashes.
  # Return date either as "5 April, 2025" or only the year "2025", depending on how much is available.
  # If the string is just 4 characters we assume it's nothing but a year, which is sometimes all we get.
  def formatted_published_date
    return if self.published_date_text.blank?

    return self.published_date_text if self.published_date_text.length === 4 # It's probably a year

    parts = self.published_date_text.split("-").map(&:to_i)
    I18n.l(Date.new(parts[0], parts[1], parts[2]), format: "%-d %B, %Y")
  end

  def published_year
    return if self.published_date_text.blank?

    return self.published_date_text if self.published_date_text.length === 4 # It's probably a year

    parts = self.published_date_text.split("-").map(&:to_i)
    parts[0]
  end

  def separated_keywords
    keywords.to_s.split(",").map(&:strip)
  end

  # When an image is attached it's height and width are saved. This is used to an
  # aspect ratio so that when an image loads it can show in the correct dimensions
  # before it has finished loading.
  def cover_aspect_ratio
    return "" if cover_original_width.blank? || cover_original_height.blank?
    "#{cover_original_width} / #{cover_original_height}"
  end

  # TODO: Add proper translation keys, this will do just fine for now though.
  def language_label
    language === "english" ? "Engels" : "Nederlands"
  end

  def format_label
    return "Hardcover" if hardcover_format?
    return "Paperback" if paperback_format?
    "Onbekend"
  end

  # Consists of 3 matchers;
  # 1. If the search result consists of nothing but 13 numbers, we assume it's an isbn and search just by that
  # 2. Large weight towards title and no fuzziness. This should prioritize exact matches of the title (or author).
  # 3. Fuzzy search for all records by their relevant fields. This includes keywords, genres, and genre keywords.
  def self.search(query, size: 50)
    is_isbn = query.match?(/\A\d{13}?\z/)

    __elasticsearch__.search({
      from: 0,
      size: size,
      query: {
        bool: {
          should: [
            (is_isbn ? { term: { isbn: query } } : nil),
            {
              multi_match: {
                query: query,
                fields: [
                  "title"
                ],
                type: "cross_fields",
                operator: "and",
                tie_breaker: 0.1,
                boost: 100,
                minimum_should_match: "50%"
              }
            },
            {
              function_score: {
                query: {
                  multi_match: {
                    query: query,
                    fields: [
                      "title^3",
                      "authors^2.5",
                      "keywords^2.5",
                      "genres^1.5",
                      "genre_keywords"
                    ],
                    fuzziness: "AUTO"
                  }
                },
                boost_mode: "sum",
                max_boost: 2
              }
            }
          ].compact
        }
      }
    }).records
  end

  def as_indexed_json(_options = {})
    {
      isbn: isbn,
      title: title,
      keywords: keywords,
      authors: authors.map(&:name),
      genres: genres.map(&:name),
      genre_keywords: genres.flat_map { |g| g.keywords.to_s.split(",").map(&:strip) }
    }
  end

  def cache_cover_urls
    update_columns(
      cover_url_large: Rails.application.routes.url_helpers.rails_public_blob_url(cover_image.variant(:large).processed),
      cover_url_small: Rails.application.routes.url_helpers.rails_public_blob_url(cover_image.variant(:small).processed)
    )
  end
end
