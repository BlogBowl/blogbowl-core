module CoreHelper
  def current_user
    Current.user
  end

  def pagy_navigation
    if @pagy.pages > 1
      content_tag(:div, class: 'flex items-center justify-center mt-10') do
        pagy_nav(@pagy).html_safe
      end
    end
  end
end
