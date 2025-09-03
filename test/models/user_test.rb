require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:user_regular)
  end

  test "Requires username" do
    @user.username = nil

    refute @user.valid?
    assert_includes @user.errors[:username], "can't be blank"
  end

  test "Username must be unique (case insensitive)" do
    duplicate = User.new(username: @user.username.upcase, password: "anotherpassword")

    refute duplicate.valid?
    assert_includes duplicate.errors[:username], "has already been taken"
  end

  test "Username format allows letters, digits, underscores, and hyphens" do
    @user.username = "valid_name-123"

    assert @user.valid?

    ["invalid!", "spaces are bad", "symbols$%"].each do |name|
      @user.username = name
      refute @user.valid?, "#{name.inspect} should be invalid"
    end
  end

  test "Should clamp username length" do
    @user.username = "abc"
    refute @user.valid?
    assert_includes @user.errors[:username], "is too short (minimum is 4 characters)"

    @user.username = "a" * 33
    refute @user.valid?
    assert_includes @user.errors[:username], "is too long (maximum is 32 characters)"
  end

  test "Requires password when creating" do
    new_user = User.new(username: "newuser")

    refute new_user.valid?
    assert_includes new_user.errors[:password], "can't be blank"
  end

  test "Validates Password length minimum" do
    @user.password = "short"

    refute @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 8 characters)"
  end

  test "Has many remember_tokens with dependent destroy" do
    association = User.reflect_on_association(:remember_tokens)

    assert_equal :has_many, association.macro
    assert_equal :destroy, association.options[:dependent]
  end

  test "Validates password is hashed" do
    user = User.create!(username: "secureuser", password: "securepass")

    refute_equal "securepass", user.password_digest
    assert BCrypt::Password.new(user.password_digest).is_password?("securepass")
  end
end
