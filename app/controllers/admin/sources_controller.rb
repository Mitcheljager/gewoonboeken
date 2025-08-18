class Admin::SourcesController < Admin::BaseController
  before_action :set_source, only: [:show, :edit, :update, :destroy]

  def index
    @sources = Source.all
  end

  def show
  end

  def new
    @source = Source.new
  end

  def edit
  end

  def create
    @source = Source.new(source_params)

    if @source.save
      redirect_to [:admin, @source], notice: "Source was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @source.update(source_params)
      redirect_to [:admin, @source], notice: "Source was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @source.destroy!
    redirect_to admin_sources_path, notice: "Source was successfully destroyed.", status: :see_other
  end

  private

  def set_source
    @source = Source.find_by_slug!(params.expect(:slug))
  end

  def source_params
    params.expect(source: [
      :name, :slug, :base_url, :affiliate_param_string, :logo,
      :shipping_cost, :shipping_cost_currency, :shipping_cost_free_from_price, :shipping_cost_free_from_quantity,
      :disabled
    ])
  end
end
