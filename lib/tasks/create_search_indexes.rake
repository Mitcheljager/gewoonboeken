desc "Create search indexes"
task create_search_indexes: :environment do
  Book.__elasticsearch__.create_index! force: true
  Book.import(force: true)
end
