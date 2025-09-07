module Authors
  class AuthorLinksController < ApplicationController
    layout 'dashboard'

    before_action :set_author
    before_action :set_link, only: [:edit, :update, :destroy]
    before_action :set_social_media_options

    def new
      @link = @author.author_links.new
      render template: "authors/links/new"
    end

    def create
      @link = @author.author_links.new(link_params)
      if @link.save
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.append("social_media_list", partial: "authors/links/link", locals: { link: @link }) }
          format.html { redirect_to edit_author_path, notice: 'Link was successfully created.' }
        end
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      render template: "authors/links/edit"
    end

    def update
      if @link.update(link_params)
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.replace(ActionView::RecordIdentifier.dom_id(@link), partial: "authors/links/link", locals: { link: @link }) }
          format.html { redirect_to edit_author_path, notice: 'Link was successfully updated.' }
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @link.destroy
      respond_to do |format|
        format.html { redirect_to edit_author_path, notice: 'Link was successfully deleted.' }
      end
    end

    private

    def set_author
      @author = @workspace.authors.where(active: true).find_by(slug: params[:author_id])
      render_not_found if @author.nil?
    end

    def set_link
      @link = @author.author_links.find_by(id: params[:id])
    end

    def link_params
      params.require(:author_link).permit(:title, :url)
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
end
