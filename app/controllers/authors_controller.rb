class AuthorsController < ApplicationController
  layout "dashboard"
  include Pagy::Backend

  before_action :set_author, only: [:edit, :update, :deactivate]

  def index
    @pagy, @authors = pagy(@workspace.authors.where(active: true).order(created_at: :asc), page: params[:page] || 1, limit: 10)
    @can_manage_members = can? :manage, Member.build(workspace: @workspace)
  end

  def edit
    authorize! :edit, @author
  end

  def update
    authorize! :edit, @author
    if @author.update(author_params)
      flash[:notice] = "Author was updated successfully."
      redirect_to authors_path
    else
      flash.now[:alert] = @author.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def deactivate
    authorize! :manage, Member.build(workspace: @workspace)
    if @author.update(active: false)
      flash[:notice] = "Author was deactivated successfully."
      redirect_to authors_path
    else
      flash[:alert] = @author.errors.full_messages.to_sentence
      redirect_to authors_path
    end
  end

  private

  def current_ability
    @current_ability ||= AuthorAbility.new(current_user).merge(MemberAbility.new(current_user))
  end

  def set_author
    @author = @workspace.authors.where(active: true).find_by(slug: params[:id])
    render_not_found if @author.nil?
  end

  def author_params
    params.require(:author).permit(:first_name, :last_name, :email, :position, :long_description, :avatar_picture, :og_image, :remove_avatar_picture, :remove_og_image)
  end
end
