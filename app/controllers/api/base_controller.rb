class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :reject_unless_token

  private

  def reject_unless_token
    token = request.headers["Token"].to_s
    head :unauthorized if token != ENV["INTERNAL_API_TOKEN"]
  end
end
