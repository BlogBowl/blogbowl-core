class Pages::Settings::LinksController < Pages::Settings::ApplicationController
  before_action :set_link, only: [:edit, :update, :destroy]
  before_action :set_social_media_options

  def new
    @link = @page.links.new(location: params[:location], link_type: params[:link_type] || "link")
    render template: "pages/settings/links/new"
  end

  def create
    @link = @page.links.new(link_params)
    if @link.save
      respond_to do |format|
        if link_params[:link_type] == 'social_media'
          format.turbo_stream { render turbo_stream: turbo_stream.append("social_media_list", partial: "pages/settings/links/link", locals: { link: @link }) }
        else
          format.turbo_stream { render turbo_stream: turbo_stream.append("link_list", partial: "pages/settings/links/link", locals: { link: @link }) }
        end
        format.html { redirect_to edit_pages_settings_header_path, notice: 'Link was successfully created.' }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render template: "pages/settings/links/edit"
  end

  def update
    if @link.update(link_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(ActionView::RecordIdentifier.dom_id(@link), partial: "pages/settings/links/link", locals: { link: @link }) }
        format.html { redirect_to edit_pages_settings_header_path, notice: 'Link was successfully updated.' }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy
    respond_to do |format|
      format.html { redirect_to edit_pages_settings_header_path, notice: 'Link was successfully deleted.' }
    end
  end

  private

  def set_link
    @link = @page.links.find(params[:id])
  end

  def link_params
    params.require(:link).permit(:title, :url, :link_type, :location)
  end

  def set_social_media_options
    @social_media_options = [
      %w[Twitter twitter],
      %w[Facebook facebook],
      %w[Instagram instagram],
      %w[LinkedIn linkedin],
      %w[YouTube youtube],
      %w[Pinterest pinterest],
      %w[TikTok tiktok],
      %w[Telegram telegram],
      %w[Discord discord],
      %w[Mastodon mastodon],
      %w[GitHub github],
    ]
  end
end

