class MessagesController < ApplicationController
  def index
    @messages = current_user.messages.order(created_at: :desc)
  end

  def show
    @message = current_user.messages.find(params[:id])
  end

  def new
    @message = current_user.messages.new
    respond_to do |format|
      format.turbo_stream
    end
  end

  def create
    @message = current_user.messages.create(message_params)
    respond_to do |format|
      format.turbo_stream do
        component = if @message.persisted?
                      MessageComponent.new(message: @message)
                    else
                      MessageFormComponent.new(message: @message)
                    end
        render inline: turbo_stream.replace('new_message', component.render_in(view_context))
      end
      format.html do
        redirect_to user_message_path(current_user, @message)
      end
    end
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
    message = current_user.messages.find(params[:id])
    message.destroy
    respond_to do |format|
      format.turbo_stream do
        if request.referrer == user_messages_url(current_user)
          render turbo_stream: turbo_stream.remove(message)
        else
          redirect_to user_messages_path(current_user), status: :see_other, notice: 'Message was deleted'
        end
      end
      format.html { redirect_to user_messages_path }
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end
end
