require "test_helper"

class GenreTest < ActiveSupport::TestCase
  test "Is valid with a fixture" do
    assert_predicate genres(:genre_one), :valid?
  end

  test "Is invalid without a name" do
    genre = Genre.new(slug: "no-name")

    refute_predicate genre, :valid?
    assert_includes genre.errors[:name], "can't be blank"
  end

  test "Is invalid without a slug" do
    genre = Genre.new(name: "No Slug")

    refute_predicate genre, :valid?
    assert_includes genre.errors[:slug], "can't be blank"
  end

  test "Name must be unique" do
    existing = genres(:genre_one)
    duplicate = Genre.new(name: existing.name, slug: "different-slug")

    refute_predicate duplicate, :valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "Slug must be unique" do
    existing = genres(:genre_two)
    duplicate = Genre.new(name: "Another Name", slug: existing.slug)

    refute_predicate duplicate, :valid?
    assert_includes duplicate.errors[:slug], "has already been taken"
  end

  test "Can have a parent genre" do
    child = genres(:genre_three)
    parent = genres(:genre_one)

    assert_equal parent, child.parent_genre
    assert_includes parent.subgenres, child
  end

  test "dependent: :nullify on subgenres" do
    parent = Genre.create!(name: "TempParent", slug: "temp-parent")
    child = Genre.create!(name: "TempChild", slug: "temp-child", parent_genre: parent)

    parent.destroy
    assert_nil child.reload.parent_genre_id
  end

  test "#to_param returns slug" do
    genre = genres(:genre_four)

    assert_equal "fantasy", genre.to_param
  end

  test "#separated_keywords returns array of trimmed words" do
    genre = genres(:genre_one)

    assert_equal ["novel", "literature"], genre.separated_keywords
  end

  test "#separated_keywords returns empty array if nil" do
    genre = genres(:genre_four)

    assert_equal [], genre.separated_keywords
  end
end
