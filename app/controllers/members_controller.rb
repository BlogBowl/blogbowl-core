class MembersController < ApplicationController
  layout 'dashboard'

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
    user = User.find_by(email: params[:email])
    if user.present? && @workspace.members.include?(@workspace.member_of_user(user))
      set_new_member
      flash.now[:alert] = "This user is already a member of this workspace."
      render :new, status: :unprocessable_entity
      return
    end

    @member = @workspace.members.build
    authorize! :manage, @member
    Member.transaction do
      if user.nil?
        validate_password
        user = User.create!(
          email: params[:email],
          password: params[:password],
          skip_workspace_creation: true
        )
      end
      @member.user = user
      set_permissions
      create_author_if_requested
      @member.save!

      # TODO: PRO
      # if @workspace.free? && @workspace.members.count >= 1
      #   flash.now[:alert] = "To invite new member, please, upgrade to a paid plan!"
      #   render :new, status: :unprocessable_entity and return
      # end
      # send_existing_user_invite_email if user.present?
      # send_new_user_invite_email unless user.present?

      flash[:notice] = "User was successfully created."
      redirect_to members_path
    end
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:alert] = e.record.errors.full_messages.to_sentence
    render :new, status: :unprocessable_entity
  end

  def edit
    authorize! :manage, @member
  end

  def update
    authorize! :manage, @member
    Member.transaction do
      update_password!

      create_author_if_requested

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

  def validate_password
    if params[:password] != params[:password_confirmation]
      @member.errors.add(:password_confirmation, "doesn't match Password")
      raise ActiveRecord::RecordInvalid, @member
    end
  end

  def update_password!
    return if params[:password].blank?

    validate_password

    @member.user.update!(password: params[:password])
  end

  def current_ability
    @current_ability ||= MemberAbility.new(current_user)
  end

  def create_author_if_requested
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

    unless params[:posts_role].in?(%w[owner admin editor writer])
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

    unless params[:posts_role].in?(%w[owner admin editor writer])
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

  # TODO: PRO
  # def send_existing_user_invite_email
  #   InvitationMailer.with(token: InvitationService.instance.generate_token(@member, email: params[:email], from: current_user, posts_has_own_author: params[:posts_has_own_author]),
  #                         email: params[:email],
  #                         workspace_title: @workspace.title).invite_existing_user.deliver_later
  # end
  #
  # def send_new_user_invite_email
  #   InvitationMailer.with(token: InvitationService.instance.generate_token(@member, email: params[:email], from: current_user, posts_has_own_author: params[:posts_has_own_author]),
  #                         email: params[:email],
  #                         workspace_title: @workspace.title).invite_new_user.deliver_later
  # end
end
