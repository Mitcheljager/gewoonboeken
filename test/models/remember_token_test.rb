require "test_helper"

class RememberTokenTest < ActiveSupport::TestCase
  def setup
    @remember_token = remember_tokens(:one)
  end

  test "Requires token" do
    @remember_token.token = nil

    assert_not @remember_token.valid?
    assert_includes @remember_token.errors[:token], "can't be blank"
  end

  test "Belongs to a user" do
    assert_kind_of User, @remember_token.user
  end
end
