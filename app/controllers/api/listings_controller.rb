class Api::ListingsController < Api::BaseController
  def update
    book = Book.find_by_isbn!(params[:isbn])
    source = Source.find_by_name!(params[:source_name])
    listing = Listing.find_or_initialize_by(book_id: book.id, source_id: source.id)

    listing.assign_attributes(listing_params)
    listing.last_scraped_at = DateTime.now

    if listing.save
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def listing_params
    params.expect(listing: [:url, :price, :description, :number_of_pages, :condition, :available, :published_date_text, :price_includes_shipping])
  end
end
