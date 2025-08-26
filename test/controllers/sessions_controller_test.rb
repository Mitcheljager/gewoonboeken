require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_regular)
  end

  test "Redirects from new if user is already logged in" do
    sign_in(@user)
    get login_path

    assert_redirected_to root_path
  end

  test "Sets return_to when visiting login with acceptable referrer" do
    get login_path, headers: { "HTTP_REFERER" => root_url }

    assert_equal root_url, session[:return_to]
  end

  test "Does not set return_to for external referrer" do
    get login_path, headers: { "HTTP_REFERER" => "https://external.com/path" }

    assert_nil session[:return_to]
  end

  test "Login with valid credentials" do
    post sessions_path, params: { username: @user.username, password: "password" }

    assert_equal @user.id, session[:user_id]
    assert_redirected_to root_path
  end

  test "Login with return_to redirects back" do
    get login_path, headers: { "HTTP_REFERER" => about_url }
    post sessions_path, params: { username: @user.username, password: "password" }

    assert_redirected_to about_url
  end

  test "Login with invalid credentials" do
    post sessions_path, params: { username: @user.username, password: "wrong" }

    assert_redirected_to login_path
    assert_equal "Username or password is invalid", flash[:alert]
  end

  test "Logout destroys session and tokens" do
    @user.remember_tokens.create!(token: "some-token")

    sign_in(@user)
    get logout_path

    assert_redirected_to login_path
    assert_nil session[:user_id]
    assert_equal 0, @user.remember_tokens.count
  end
end
