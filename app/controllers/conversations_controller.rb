class ConversationsController < ApplicationController
  def index
    @conversations = current_user.conversations.order(created_at: :desc)
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
