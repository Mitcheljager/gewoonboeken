require "test_helper"

class BookTest < ActiveSupport::TestCase
  def setup
    @book = books(:book_one)
    @book_two = books(:book_two)
  end

  test "Requires title" do
    @book.title = nil

    refute @book.valid?
    assert_includes @book.errors[:title], "can't be blank"
  end

  test "Requires isbn of 13 digits" do
    @book.isbn = "123"

    refute @book.valid?
    assert_includes @book.errors[:isbn], "is invalid"
  end

  test "Requires unique isbn" do
    duplicate = Book.new(title: "Dup", isbn: @book.isbn, format: :paperback)

    refute duplicate.valid?
    assert_includes duplicate.errors[:isbn], "has already been taken"
  end

  test "Accepts nil language" do
    @book.language = nil

    assert @book.valid?
  end

  test "Destroying book destroys its listings" do
    listing_ids = @book.listings.pluck(:id)
    @book.destroy

    assert_empty Listing.where(id: listing_ids)
  end

  test "to_param includes title and isbn" do
    assert_match @book.isbn, @book.to_param
    assert_match @book.title.parameterize, @book.to_param
  end

  test "listings_with_price only returns listings with price > 0 and available" do
    assert @book.listings_with_price.all? { |listing| listing.price.to_f > 0 && listing.available? }
  end

  test "lowest_price returns the cheapest listing price" do
    prices = @book.listings_with_price.map(&:price)

    assert_equal prices.min, @book.lowest_price
  end

  test "cheapest_listing returns the listing with lowest price" do
    cheapest = @book.listings_with_price.min_by(&:price)

    assert_equal cheapest, @book.cheapest_listing
  end

  test "formatted_number_of_pages returns dash if zero" do
    @book.number_of_pages = 0

    assert_equal "-", @book.formatted_number_of_pages
  end

  test "formatted_number_of_pages uses dot delimiter" do
    @book.number_of_pages = 1234

    assert_equal "1.234", @book.formatted_number_of_pages
  end

  test "formatted_published_date returns year if only 4 chars" do
    @book.published_date_text = "2005"

    assert_equal "2005", @book.formatted_published_date
  end

  test "published_year extracts year" do
    @book.published_date_text = "1999-10-30"

    assert_equal 1999, @book.published_year
  end

  test "separated_keywords splits on commas" do
    @book.keywords = "alpha, beta, gamma"

    assert_equal ["alpha", "beta", "gamma"], @book.separated_keywords
  end

  test "cover_aspect_ratio returns string" do
    assert_equal "600 / 900", @book.cover_aspect_ratio
  end

  test "language_label maps english to Engels" do
    @book.language = "english"

    assert_equal "Engels", @book.language_label
  end

  test "format_label returns Hardcover" do
    @book.format = :hardcover
    assert_equal "Hardcover", @book.format_label
  end

  test "Requires_scrape? true if last_scrape_started_at nil" do
    @book.last_scrape_started_at = nil

    assert @book.requires_scrape?
  end

  test "is_scrape_ongoing? true when finished_at < started_at" do
    @book.last_scrape_started_at = 2.minutes.ago
    @book.last_scrape_finished_at = 5.minutes.ago

    assert @book.is_scrape_ongoing?
  end

  test "is_scrape_frozen? true if started more than 10 min ago and not finished" do
    @book.last_scrape_started_at = 15.minutes.ago
    @book.last_scrape_finished_at = nil

    assert @book.is_scrape_frozen?
  end
end
