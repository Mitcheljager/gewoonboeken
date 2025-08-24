require "test_helper"

class Api::BaseControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = "some-token"
    ENV["INTERNAL_API_TOKEN"] = @token
  end

  test "allows request with correct token" do
    get api_ping_url, headers: { "Token" => @token }

    assert_response :success
    assert_equal({ "message" => "pong" }, JSON.parse(response.body))
  end

  test "rejects request with missing token" do
    get api_ping_url

    assert_response :unauthorized
  end

  test "rejects request with invalid token" do
    get api_ping_url, headers: { "Token" => "wrong-token" }

    assert_response :unauthorized
  end
end
