# test/controllers/application_controller_test.rb
require "test_helper"

class DummyController < ApplicationController
  def index
    render json: {
      theme: theme_dark? ? "dark" : "light",
      current_user_id: current_user&.id,
      filters: filter_params,
      any_filters: any_filter_params?
    }
  end

  def needs_user
    redirect_unless_current_user
  end

  def needs_admin
    redirect_unless_admin
  end
end

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user_regular)
    @admin = users(:user_admin)
  end

  test "Sets client hints headers" do
    get "/dummy"

    assert_equal "Sec-CH-Prefers-Color-Scheme", response.headers["Vary"]
    assert_equal "Sec-CH-Prefers-Color-Scheme", response.headers["Accept-CH"]
    assert_match(/ch-prefers-color-scheme/, response.headers["Permissions-Policy"])
  end

  test "Theme comes from cookie" do
    cookies[:theme] = "dark"

    get "/dummy"

    body = JSON.parse(response.body)
    assert_equal "dark", body["theme"]
  end

  test "Theme comes from header if no cookie" do
    cookies[:theme] = nil

    get "/dummy", headers: { "Sec-CH-Prefers-Color-Scheme" => "dark" }
    body = JSON.parse(response.body)

    assert_equal "dark", body["theme"]
  end

  test "current_user returns nil if no session" do
    get "/dummy"
    body = JSON.parse(response.body)

    assert_nil body["current_user_id"]
  end

  test "current_user returns user if session set" do
    sign_in(@admin)
    get "/dummy"

    body = JSON.parse(response.body)

    assert_equal @admin.id, body["current_user_id"]
  end

  test "redirect_unless_current_user redirects" do
    get "/dummy/needs_user"

    assert_response :see_other
    assert_redirected_to login_path
  end

  test "redirect_unless_admin redirects non-admin" do
    sign_in(@user)

    get "/dummy/needs_admin"

    assert_response :see_other
    assert_redirected_to root_path
  end

  test "Filter_params permits only expected keys" do
    get "/dummy", params: { query: "test", not: "permitted" }
    body = JSON.parse(response.body)

    assert_includes body["filters"].keys, "query"
    refute_includes body["filters"].keys, "not"
  end

  test "Detects present filters" do
    get "/dummy", params: { query: "test" }
    body = JSON.parse(response.body)

    assert body["any_filters"]

    get "/dummy"
    body = JSON.parse(response.body)

    refute body["any_filters"]
  end
end
