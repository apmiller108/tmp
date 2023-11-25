class MessagesController < ApplicationController
  def index
    @messages = current_user.messages
  end

  def show
    @message = current_user.messages.find(params[:id])
  end

  def new
    @message = current_user.messages.new
  end

  def create
    message = current_user.messages.create!(params.require(:message).permit(:content))
    redirect_to user_message_path(current_user, message)
  end

  def edit
    @message = current_user.messages.find(params[:id])
  end

  def update
    message = current_user.messages.find(params[:id])
    message.update(message_params)
    redirect_to user_message_path(current_user, message)
  end

  def destroy
    @message = current_user.messages.find(params[:id])
    @message.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@message) }
      format.html { redirect_to user_messages_path }
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
