class MessagesController < ApplicationController
  def index
  end

  def show
    @message = Message.find(params[:id])
  end

  def new
    @message = current_user.messages.new
  end

  def create
    message = current_user.messages.create!(params.require(:message).permit(:content))
    redirect_to message
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
