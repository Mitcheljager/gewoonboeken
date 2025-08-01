class BookFilter
  attr_reader :books, :params

  def initialize(books = Book.all, params = {})
    @books = books
    @params = params
  end

  def filter
    filter_by_condition
    filter_by_availability
    filter_by_year
    filter_by_genres
    filter_by_formats
    filter_by_languages
    search
    sort

    @books.distinct
  end

  private

  def filter_by_condition
    return if params[:conditions].blank?

    @books = books.joins(:listings).where(listings: { condition: params[:conditions], available: true })
  end

  def filter_by_availability
    return if params[:available].nil?

    available = ActiveModel::Type::Boolean.new.cast(params[:available])
    @books = books.joins(:listings).where(listings: { available: available }).where.not(listings: { price: 0 }).where.not(listings: { price: 0 })
  end

  def filter_by_year
    return if params[:year_from].blank? && params[:year_to].blank?

    from = (params[:year_from]&.to_i || 0).clamp(0, Date.current.year)
    to = (params[:year_to]&.to_i || Date.current.year).clamp(from, Date.current.year)

    @books = books.where("CAST(SUBSTR(books.published_date_text, 1, 4) AS INTEGER) BETWEEN ? AND ?", from, to)
  end

  def filter_by_genres
    return if params[:genres].blank?

    genre_ids = Genre.where(slug: Array(params[:genres])).pluck(:id)
    @books = books.joins(:genres).where(genres: { id: genre_ids })
  end

  def filter_by_formats
    return if params[:formats].blank?

    @books = books.where(format: params[:formats])
  end

  def filter_by_languages
    return if params[:languages].blank?

    @books = books.where(language: params[:languages])
  end

  def search
    return if params[:query].blank?

    @books = books.search(params[:query].strip)
  end

  def sort
    if params[:sort] == "new"
      @books = books.order(Arel.sql("published_date_text DESC"))
    elsif params[:sort] == "old"
      @books = books.order(Arel.sql("published_date_text ASC"))
    elsif params[:query].present?
      @books = books
    else
      @books = books.order(hotness: :desc)
    end
  end
end
