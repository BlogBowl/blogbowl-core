class Pages::Settings::FooterController < Pages::Settings::ApplicationController
  before_action :set_links, only: [:edit]

  def edit
  end

  def update
    @page.transaction do
      update_settings!
      update_order!
      flash[:notice] = "Page settings were updated successfully."
      redirect_to edit_pages_settings_footer_path
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(:copyright, :with_sitemap, :with_rss)
  end

  def links_params
    params.require(:links).map do |link_params|
      link_params.permit(:id, :order)
    end
  end

  def update_settings!
    @page_settings.update!(page_setting_params)
  end

  def update_order!
    links_params.each_with_index do |link_params, idx|
      link = @page.links.find(link_params[:id])
      link.update!(order: link_params[:order].presence || idx) if link.present?
    end
  end

  def set_links
    @links = @page.links.footer.where(link_type: 'link').order(:order)
    @social_media_links = @page.links.where(link_type: 'social_media')
  end
end

