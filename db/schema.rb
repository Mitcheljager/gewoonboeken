# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_02_28_130740) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "record_type", limit: 255, null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "filename", limit: 255, null: false
    t.string "content_type", limit: 255
    t.text "metadata"
    t.string "service_name", limit: 255, null: false
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", limit: 255, null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", force: :cascade do |t|
    t.integer "visit_id"
    t.integer "user_id"
    t.string "name", limit: 255
    t.text "properties"
    t.datetime "time", precision: nil
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", force: :cascade do |t|
    t.string "visit_token", limit: 255
    t.string "visitor_token", limit: 255
    t.integer "user_id"
    t.string "ip", limit: 255
    t.text "user_agent"
    t.text "referrer"
    t.string "referring_domain", limit: 255
    t.text "landing_page"
    t.string "browser", limit: 255
    t.string "os", limit: 255
    t.string "device_type", limit: 255
    t.string "country", limit: 255
    t.string "region", limit: 255
    t.string "city", limit: 255
    t.float "latitude"
    t.float "longitude"
    t.string "utm_source", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_term", limit: 255
    t.string "utm_content", limit: 255
    t.string "utm_campaign", limit: 255
    t.string "app_version", limit: 255
    t.string "os_version", limit: 255
    t.string "platform", limit: 255
    t.datetime "started_at", precision: nil
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "slug", limit: 255
    t.string "description", limit: 255
  end

  create_table "book_authors", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "author_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["author_id"], name: "index_book_authors_on_author_id"
    t.index ["book_id"], name: "index_book_authors_on_book_id"
  end

  create_table "book_genres", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "genre_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["book_id"], name: "index_book_genres_on_book_id"
    t.index ["genre_id"], name: "index_book_genres_on_genre_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", limit: 255
    t.string "isbn", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "language", limit: 255
    t.integer "number_of_pages", default: 0
    t.string "subtitle", limit: 255
    t.string "description", limit: 255
    t.integer "format", default: 0, null: false
    t.datetime "last_scrape_finished_at", precision: nil
    t.datetime "description_last_generated_at", precision: nil
    t.string "published_date_text", limit: 255
    t.string "keywords", limit: 255
    t.integer "cover_original_width"
    t.integer "cover_original_height"
    t.datetime "last_scrape_started_at", precision: nil
    t.integer "hotness", default: 0, null: false
    t.datetime "cover_last_scraped_at", precision: nil
    t.float "listings_lowest_price_cache", default: 0.0
    t.integer "listings_available_count_cache", default: 0
    t.string "cover_url_large"
    t.string "cover_url_small"
    t.index ["hotness"], name: "index_books_on_hotness"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.integer "parent_genre_id"
    t.string "keywords", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "books_count", default: 0, null: false
    t.index ["parent_genre_id"], name: "index_genres_on_parent_genre_id"
  end

  create_table "indexed_listing_urls", force: :cascade do |t|
    t.string "source_name"
    t.string "isbn"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listings", force: :cascade do |t|
    t.integer "book_id"
    t.integer "source_id"
    t.float "price"
    t.string "currency", limit: 255
    t.string "url", limit: 255
    t.datetime "last_scraped_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "number_of_pages"
    t.string "description", limit: 255
    t.boolean "was_last_scrape_successful"
    t.integer "condition", default: 0, null: false
    t.string "condition_details", limit: 255
    t.boolean "available", default: false
    t.string "published_date_text", limit: 255
    t.boolean "price_includes_shipping", default: false
    t.datetime "last_search_api_request_at", precision: nil
  end

  create_table "remember_tokens", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "token", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_remember_tokens_on_user_id"
  end

  create_table "requested_isbns", force: :cascade do |t|
    t.string "isbn", limit: 255
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "rollups", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "interval", limit: 255, null: false
    t.datetime "time", precision: nil, null: false
    t.float "value"
    t.index ["name", "interval", "time"], name: "index_rollups_on_name_and_interval_and_time", unique: true
  end

  create_table "skippable_isbns", force: :cascade do |t|
    t.string "isbn", limit: 255
    t.boolean "permanent"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "sources", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "slug", limit: 255
    t.string "base_url", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "shipping_cost", default: 0.0
    t.string "shipping_cost_currency", limit: 255, default: "EUR"
    t.float "shipping_cost_free_from_price", default: 0.0
    t.integer "shipping_cost_free_from_quantity", default: 0
    t.boolean "disabled", default: false
    t.string "affiliate_param_string"
    t.index ["slug"], name: "index_sources_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", limit: 255
    t.string "password_digest", limit: 255
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit", limit: 255
    t.datetime "created_at", precision: nil
    t.bigint "item_id", null: false
    t.string "item_type", limit: 255, null: false
    t.string "event", limit: 255, null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_authors", "authors"
  add_foreign_key "book_authors", "books"
  add_foreign_key "book_genres", "books"
  add_foreign_key "book_genres", "genres"
  add_foreign_key "genres", "genres", column: "parent_genre_id"
  add_foreign_key "remember_tokens", "users"
end
