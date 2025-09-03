require "test_helper"

class SourceTest < ActiveSupport::TestCase
  def setup
    @source = sources(:source_one)
  end

  test "Requires name" do
    @source.name = nil

    assert_not @source.valid?
    assert_includes @source.errors[:name], "can't be blank"
  end

  test "Requires unique name (case insensitive)" do
    duplicate = Source.new(
      name: @source.name.upcase,
      slug: "boeken-dup",
      base_url: "https://dup.example.com",
      shipping_cost_currency: "EUR"
    )

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "Requires slug" do
    @source.slug = nil

    assert_not @source.valid?
    assert_includes @source.errors[:slug], "can't be blank"
  end

  test "Requires unique slug (case insensitive)" do
    duplicate = Source.new(name: "Duplicate", slug: @source.slug.upcase, base_url: "https://dup.example.com", shipping_cost_currency: "EUR")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "Requires base_url" do
    @source.base_url = nil

    assert_not @source.valid?
    assert_includes @source.errors[:base_url], "can't be blank"
  end

  test "Requires valid shipping_cost_currency" do
    @source.shipping_cost_currency = "INVALID"

    assert_not @source.valid?
    assert_includes @source.errors[:shipping_cost_currency], "INVALID is not a valid currency"
  end

  test "Has many listings with dependent destroy" do
    listings = Source.reflect_on_association(:listings)

    assert_equal :has_many, listings.macro
    assert_equal :destroy, listings.options[:dependent]
  end

  test "Renames attached logo before save" do
    source = sources(:source_two)

    source.logo.attach(
      io: File.open(Rails.root.join("test", "fixtures", "files", "logo.png")),
      filename: "randomname.png",
      content_type: "image/png"
    )

    source.save!
    assert_equal "#{source.slug}.png", source.logo.blob.filename.to_s
  end

  test "#to_param returns slug" do
    assert_equal @source.slug, @source.to_param
  end
end
