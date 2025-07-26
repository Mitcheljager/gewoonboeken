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
    attachable.variant(:large,       resize_to_limit: [300, 500], quality: 80, format: :webp, preprocessed: true)
    attachable.variant(:small_wide,  resize_to_limit: [250, 190], quality: 80, format: :webp, preprocessed: true)
    attachable.variant(:small,       resize_to_limit: [120, 190], quality: 80, format: :webp, preprocessed: true)
  end

  enum :format, [:unknown, :paperback, :hardcover], suffix: true
  enum :language, { dutch: "nl", english: "en" }

  validates :title, presence: true
  validates :isbn, presence: true, uniqueness: true, format: { with: /\A[0-9]+\z/ }
  validates :format, inclusion: { in: Book.formats.keys }
  validates :language, inclusion: { in: Book.languages.keys }, allow_nil: true
  validates :published_date_text, format: { with: /\A[0-9\-]+\z/ }, allow_nil: true, allow_blank: true

  accepts_nested_attributes_for :book_authors, allow_destroy: true
  accepts_nested_attributes_for :book_genres, allow_destroy: true

  def to_param
    "#{title.parameterize}-#{isbn}"
  end

  def listings_with_price
    listings.where.not(price: 0).where(available: true).order(price: :asc)
  end

  def lowest_price
    listings_with_price.pluck(:price).sort.first
  end

  def cheapest_listing
    listings_with_price.sort_by(&:price).first
  end

  def authors_human_list
    human_list(authors.pluck(:name))
  end

  def requires_scrape?
    # Requires scrape if scrape is not ongoing
    !is_scrape_ongoing? &&
    # and a scrape has never been started, or the last scrape is past the threshold.
    (last_scrape_started_at.blank? || (last_scrape_finished_at.present? && last_scrape_finished_at < 1.day.ago))
  end

  def is_scrape_ongoing?
    return false if last_scrape_started_at.blank?

    # Check if a scrape is ongoing either by checking if a start datetime exists without an end datetime,
    (last_scrape_started_at.present? && last_scrape_finished_at.blank?) ||
    # or by checking if the finished datetime is before the end datetime, indicating that it has not yet finished.
    (last_scrape_finished_at.present? && (last_scrape_finished_at < last_scrape_started_at))
  end

  def should_show_scrape_message?
    requires_scrape? || is_scrape_ongoing?
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

  # Keywords are a comma separated list, use this method to get them as an array
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
    language === "en" ? "Engels" : "Nederlands"
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
                  "title^4",
                  "authors^3",
                  "keywords^2",
                  "genres^2",
                  "genre_keywords"
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
end
