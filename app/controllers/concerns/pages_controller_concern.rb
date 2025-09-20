module PagesControllerConcern
  extend ActiveSupport::Concern

  included do
    layout 'dashboard'
  end

  def show
    redirect_to pages_posts_url(@workspace.pages.find_by(name_slug: params[:id]))
  end

  def index
    @pages = @workspace.pages
  end

  def new
    @page = @workspace.pages.build
  end

  def create
    # TODO: PRO
    # if @workspace.free? && @workspace.pages.count >= 1
    #   flash.now[:alert] = "To add new page, please, upgrade to a paid plan!"
    #   render :new, status: :unprocessable_entity and return
    # end

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
