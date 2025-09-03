require "test_helper"

class IndexedListingUrlTest < ActiveSupport::TestCase
  def setup
    @url = indexed_listing_urls(:one)
  end

  test "Requires source_name" do
    @url.source_name = nil

    assert_not @url.valid?
    assert_includes @url.errors[:source_name], "can't be blank"
  end

  test "Requires isbn" do
    @url.isbn = nil

    assert_not @url.valid?
    assert_includes @url.errors[:isbn], "can't be blank"
  end

  test "isbn must be 13 digits" do
    @url.isbn = "12345"

    assert_not @url.valid?
    assert_includes @url.errors[:isbn], "is invalid"

    @url.isbn = "9781234567890"
    assert @url.valid?
  end

  test "Requires url" do
    @url.url = nil

    assert_not @url.valid?
    assert_includes @url.errors[:url], "can't be blank"
  end
end
