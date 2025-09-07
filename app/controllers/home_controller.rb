class HomeController < ApplicationController
  def index
    redirect_to pages_path
  end
end
