class Pages::Settings::HeaderController < Pages::Settings::ApplicationController
  def edit
    set_links
  end

  def update
    @page.transaction do
      update_settings!
      update_order!
      flash[:notice] = "Page settings were updated successfully."
      redirect_to edit_pages_settings_header_path
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(:logo, :remove_logo, :logo_text, :logo_link, :header_cta_button, :header_cta_button_link, :with_search, :header_cta_enabled)
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
    @links = @page.links.header
  end
end

