class Pages::Settings::BillingController < Pages::Settings::ApplicationController
  def edit
    @subscription = @page.stripe_subscription&.subscription
  end

  def cancel_subscription
    begin
      StripeService::cancel_subscription(@page.stripe_subscription.subscription_id, true)
      flash[:notice] = "Subscription canceled successfully."
    rescue => e
      Rails.logger.error "Failed to cancel subscription. Please try again.: #{e.message}"
      # TODO: PRO
      # Sentry.capture_exception(e, extra: { workspace_id: @page.workspace_id, page_id: @page.id })
      flash[:alert] = "Failed to cancel subscription. Please try again."
    end
    redirect_to edit_pages_settings_billing_path
  end

  def update
    if @page_settings.update(page_setting_params)
      flash[:notice] = "Blog settings were updated successfully."
      redirect_to edit_pages_settings_cta_path
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(
      :cta_title,
      :cta_description,
      :cta_button,
      :cta_button_link,
      :cta_enabled,
      )
  end

end

