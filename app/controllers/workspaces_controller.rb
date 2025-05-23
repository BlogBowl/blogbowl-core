class WorkspacesController < ApplicationController
  layout "authentication"
  skip_before_action :set_workspace

  def index
    @workspaces = current_user.workspaces
  end

  def create
    workspace = Workspace.new(title: "My Workspace #{current_user.workspaces.count + 1}")
    member = current_user.members.create!(workspace:, permissions: ["owner"])
    member.create_or_activate_author!
    if workspace.save
      flash[:notice] = "New workspace was created successfully."
      session[:workspace_id] = workspace.id
      Current.workspace_id = workspace.id
      redirect_to pages_path
    else
      flash.now[:alert] = workspace.errors.full_messages.to_sentence
      render :index, status: :unprocessable_entity
    end
  end

  def show
    workspace = current_user.workspaces.find_by(id: params[:id])
    render_not_found and return if workspace.nil?

    session[:workspace_id] = workspace.id
    Current.workspace_id = workspace.id
    redirect_to pages_path
  end
end
