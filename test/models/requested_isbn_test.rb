require "test_helper"

class RequestedIsbnTest < ActiveSupport::TestCase
  def setup
    @item = RequestedISBN.new(isbn: "1234567890123", status: :not_found)
  end

  test "Requires valid status" do
    assert_raises ArgumentError do
      @item.status = "fake_status"
    end
  end

  test "Enum generates helper methods" do
    assert_respond_to @item, :not_found!
    assert_respond_to @item, :error!
    assert_respond_to @item, :rejected!
    assert_respond_to @item, :resolved!
  end

  test "Can change status using enum" do
    @item.error!

    assert_equal "error", @item.status
  end
end
