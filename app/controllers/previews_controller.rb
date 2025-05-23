class PreviewsController < ApplicationController
  allow_unauthenticated_access

  def show
    @post_revision = PostRevision.find_by(share_id: params[:share_id])
    @post = @post_revision.post.clone

    # Overwrite common fields without saving to DB
    @post.assign_attributes(@post_revision.attributes.slice(*common_fields).compact)

    @page = @post.page
    @page_settings = @page.settings

    @workspace = @page.workspace
    @workspace_settings = @workspace.settings

    @authors = @post.authors.where(post_authors: { role: "author" })
    @reviewers = @post.authors.where(post_authors: { role: "reviewer" })
    @main_author = @authors.first || Author.new(email: "preview@preview.com", slug: "preview-author")
    @contributing_authors = @authors.where.not(id: @main_author.id) if @main_author.present?

    @navbar_links = @page.links.header.order(:order)
    @footer_links = @page.links.footer.where(link_type: "link").order(:order)
    @social_media_links = @page.links.where(link_type: "social_media").order(:order)

    render show_view, layout: "public/#{@page_settings.template}"
  end

  private

  def show_view
    "public/#{@page_settings.template}/posts/show"
  end

  def common_fields
    %w[title content_html content_json seo_title seo_description og_title og_description]
  end
end
