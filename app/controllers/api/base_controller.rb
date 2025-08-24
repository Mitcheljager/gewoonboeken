class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :reject_unless_token

  def ping
    render json: { message: "pong" }
  end

  private

  def reject_unless_token
    token = request.headers["Token"].to_s
    head :unauthorized if token != ENV["INTERNAL_API_TOKEN"]
  end
end
