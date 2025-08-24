ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

module InlineSvg
  class ViteFileLoader
    def self.named(filename)
      '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><rect width="16" height="16" fill="#ccc"/></svg>'
    end
  end
end

module ViteRails::TagHelpers
  def vite_asset_path(name, **options)
    filename = File.basename(name)
    "/vite-test/assets/#{filename}"
  end

  def vite_image_path(name, **options)
    filename = File.basename(name)
    "/vite-test/assets/#{filename}"
  end

  def vite_javascript_path(name, **options)
    filename = File.basename(name)
    "/vite-test/assets/#{filename}"
  end

  def vite_stylesheet_path(name, **options)
    filename = File.basename(name)
    "/vite-test/assets/#{filename}"
  end

  def vite_javascript_tag(name)
    filename = File.basename(name)
    javascript_include_tag("/vite-test/assets/#{filename}")
  end

  def vite_stylesheet_tag(name, **options)
    filename = File.basename(name)
    stylesheet_link_tag("/vite-test/assets/#{filename}", options)
  end

  def vite_image_tag(name, **options)
    filename = File.basename(name)
    image_tag("/vite-test/assets/#{filename}", options)
  end

  def vite_client_tag
    ""
  end

  def vite_typescript_tag(name)
    vite_javascript_tag(name)
  end
end

def sign_in(user)
  post "/sessions", params: { username: user.username, password: "password" }
end
