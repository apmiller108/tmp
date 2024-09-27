class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations.order(created_at: :desc)
  end

  def new
  end

  def create
  end

  def edit
    @conversation = current_user.conversations.find(params[:id])
  end

  def update
  end

  def destroy
  end
end
