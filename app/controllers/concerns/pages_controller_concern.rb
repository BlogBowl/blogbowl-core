module PagesControllerConcern
  extend ActiveSupport::Concern

  included do
    layout 'dashboard'
  end

  def show
    redirect_to pages_posts_url(@workspace.pages.find_by(name_slug: params[:id]))
  end

  def index
    @pages = @workspace.pages.order(created_at: :asc)
  end

  def new
    @page = @workspace.pages.build
  end

  def create
    @page = @workspace.pages.build(page_params)

    if @page.save
      flash[:notice] = 'New page was created successfully.'
      redirect_to pages_posts_path(@page)
    else
      flash.now[:alert] = @page.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def page_params
    params.require(:page).permit(:name, :slug)
  end
end
