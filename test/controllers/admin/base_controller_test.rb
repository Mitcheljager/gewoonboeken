require "test_helper"

class Admin::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:user_admin)
    @user = users(:user_regular)
  end

  test "Admin can access index" do
    sign_in(@admin)
    get admin_root_url

    assert_response :success
  end

  test "Non-admin is redirected" do
    sign_in(@user)

    assert_redirected_to root_url
  end

  test "Logged out user is redirected" do
    get admin_root_url

    assert_redirected_to root_url
  end
end
