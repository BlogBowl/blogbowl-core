class Pages::Settings::NewsletterController < Pages::Settings::ApplicationController
  before_action :set_newsletters

  def edit
  end

  def update
    if @page_settings.update(page_setting_params)
      flash[:notice] = "Page settings were updated successfully."
      redirect_to edit_pages_settings_newsletter_path(page_id: @page_settings.page.name_slug)
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_newsletters
    @newsletters = @workspace.newsletters
    @newsletter_options = @newsletters.map { |newsletter| [newsletter.name, newsletter.id] }
  end

  def page_setting_params
    params.require(:page_setting).permit(
      :newsletter_cta_enabled,
      :newsletter_cta_title,
      :newsletter_cta_description,
      :newsletter_cta_button,
      :newsletter_cta_disclaimer,
      :newsletter_id
    )
  end
end

