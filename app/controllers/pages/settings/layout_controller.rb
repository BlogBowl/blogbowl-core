class Pages::Settings::LayoutController < Pages::Settings::ApplicationController
  before_action :set_layout_templates, only: [:edit]

  def edit
  end

  def update
    if @page_settings.update(page_setting_params)
      flash[:notice] = "Blog settings were updated successfully."
      redirect_to edit_pages_settings_layout_path
    else
      flash.now[:alert] = @page_settings.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def page_setting_params
    params.require(:page_setting).permit(:template, :theme)
  end

  # TODO: Configure layout templates
  def set_layout_templates
    if Rails.env.development?
      @layout_templates = [
        { name: 'Barebone', id: 'barebone', preview_url: 'https://template-blog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/blog-1.webp' },
        { name: 'Basic', id: 'basic', preview_url: 'https://template-blog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/blog-1.webp' },
        { name: 'Blog', id: 'blog_1', preview_url: 'https://template-blog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/blog-1.webp' },
        { name: 'Changelog', id: 'changelog_1', preview_url: 'https://template-changelog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/changelog-1.webp' },
        { name: 'Help Docs', id: 'help_docs_1', preview_url: 'https://template-help-docs-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/help-docs-1.webp' },
      ]
    else
      @layout_templates = [
        { name: 'Blog', id: 'blog_1', preview_url: 'https://template-blog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/blog-1.webp' },
        { name: 'Changelog', id: 'changelog_1', preview_url: 'https://template-changelog-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/changelog-1.webp' },
        { name: 'Help Docs', id: 'help_docs_1', preview_url: 'https://template-help-docs-1.blogbowl.app/', img: 'https://blogbowl.fra1.cdn.digitaloceanspaces.com/manual_resources/help-docs-1.webp' },
      ]
    end
  end
end

