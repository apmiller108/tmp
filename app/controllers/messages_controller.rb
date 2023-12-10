class MessagesController < ApplicationController
  def index
    @messages = current_user.messages.order(created_at: :desc)
  end

  def show
    @message = current_user.messages.find(params[:id])
  end

  def new
    ActionCable.server.broadcast("hello", { body: "This Room is Best Room." })

    @message = current_user.messages.new
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @message = current_user.messages.create(message_params)
    status = @message.persisted? ? :created : :unprocessable_entity
    respond_to do |format|
      format.turbo_stream do
        render(
          inline: turbo_stream.replace('new_message', component_for(message: @message).render_in(view_context)),
          status:
        )
      end
      format.html do
        if @message.persisted?
          redirect_to user_message_path(current_user, @message)
        else
          render :new, status:
        end
      end
    end
  end

  def edit
    @message = current_user.messages.find(params[:id])
  end

  def update
    @message = current_user.messages.find(params[:id])

    if @message.update(message_params)
      redirect_to user_message_path(current_user, @message)
    else
      render :edit, status: :unprocessable_entity
    end
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

  def component_for(message:)
    if message.persisted?
      MessageComponent.new(message: @message)
    else
      MessageFormComponent.new(message: @message)
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
