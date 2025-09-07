class Pages::Settings::CodeController < Pages::Settings::ApplicationController

  def edit
  end

  def update
    head_html = params[:page_setting][:head_html]
    body_html = params[:page_setting][:body_html]

    html_errors = html_errors(head_html) || html_errors(body_html)
    if html_errors.nil?
      if @page_settings.update(head_html: head_html, body_html: body_html)
        flash[:notice] = "Page settings were updated successfully."
        redirect_to edit_pages_settings_code_path
      else
        flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = 'Invalid HTML content: ' + html_errors
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(:head_html, :body_html)
  end


  def html_errors(html)
    # Simple HTML validation logic
    # You can use a library like Nokogiri for more robust validation
    errors = Nokogiri::HTML(html).errors
    if errors.empty?
      return nil
    end
    errors.map(&:to_s).join('\n\n')
  end
end

