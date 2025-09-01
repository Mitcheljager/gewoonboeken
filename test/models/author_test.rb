require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  def setup
    @author = Author.new(
      name: "Isaac Asimov",
      slug: "isaac-asimov",
      description: "Famous sci-fi author"
    )
  end

  test "Is valid with valid attributes" do
    assert_predicate author, :valid?
  end

  test "Is invalid without a name" do
    author.name = nil
    refute_predicate author, :valid?
    assert_includes author.errors[:name], "can't be blank"
  end

  test "Is invalid without a slug" do
    author.slug = nil
    refute_predicate author, :valid?
    assert_includes author.errors[:slug], "can't be blank"
  end

  test "Name should be unique while case-insensitive" do
    Author.create!(name: "Isaac Asimov", slug: "other-slug")
    duplicate = Author.new(name: "isaac asimov", slug: "unique-slug")

    refute_predicate duplicate, :valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "Slug should be unique while case-insensitive" do
    Author.create!(name: "Another Author", slug: "isaac-asimov")
    duplicate = Author.new(name: "Unique Name", slug: "ISAAC-ASIMOV")

    refute_predicate duplicate, :valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "#to_param returns slug" do
    assert_equal "isaac-asimov", author.to_param
  end

  private

  def author
    @author
  end
end
