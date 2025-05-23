class MembersController < ApplicationController
  layout "dashboard"

  before_action :set_member, only: [:edit, :update]
  before_action :set_new_member, only: :new

  before_action :validate_update_fields, only: :update
  before_action :validate_create_fields, only: :create

  def index
    @members = @workspace.members.order(id: :asc)
    @can_manage_members = can? :manage, Member.build(workspace: @workspace)
  end

  def new
    authorize! :manage, Member.build(workspace: @workspace)
  end

  def create
    flash[:notice] = "TODO: Create a new member"
    redirect_to members_path
  end

  def edit
    authorize! :manage, @member
  end

  def update
    authorize! :manage, @member
    Member.transaction do
      update_posts!

      set_permissions
      @member.save!

      flash[:notice] = "Member was updated successfully."
      redirect_to members_path
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :edit, status: :unprocessable_entity
  end

  private

  def current_ability
    @current_ability ||= MemberAbility.new(current_user)
  end

  def update_posts!
    has_own_author = params[:posts_has_own_author] == "true"

    if has_own_author
      @member.create_or_activate_author!
    else
      @member.deactivate_author!
    end
  end

  def set_permissions
    posts_role = params[:posts_role]
    @member.permissions = [*Post.permissions_of_role(posts_role)]
  end

  def validate_update_fields
    unless params[:posts_role].present?
      flash.now[:alert] = "Posts role can't be blank"
      render :edit, status: :bad_request and return
    end

    unless params[:posts_role].in?(%w[owner editor writer])
      flash.now[:alert] = "Posts role is invalid"
      render :edit, status: :bad_request and return
    end
  end

  def validate_create_fields
    unless params[:email].present?
      flash[:alert] = "Email can't be blank"
      redirect_to new_member_path and return
    end

    unless params[:posts_role].present?
      flash[:alert] = "Posts role can't be blank"
      redirect_to new_member_path and return
    end

    unless params[:posts_role].in?(%w[owner editor writer])
      flash[:alert] = "Posts role is invalid"
      redirect_to new_member_path and return
    end

  end

  def set_member
    @member = @workspace.members.find_by(id: params[:id])
  end

  def set_new_member
    @member = @workspace.members.build(permissions: Post::WRITER_PERMISSIONS)
  end
end
