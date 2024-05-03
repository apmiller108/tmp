class ConversationsController < ApplicationController
  def index
    conversation = current_user.memos.find(params[:memo_id]).conversation
    respond_to do |format|
      format.json do
        render json: conversation.as_json(only: %i[id created_at updated_at]), status: :ok
      end
    end
  end

  def create
    form = ConversationForm.new(form_params)

    respond_to do |format|
      format.json do
        if form.save
          render json: form.conversation.as_json(only: %i[id created_at updated_at]), status: :created
        else
          render json: {
            error: { message: form.errors.full_messages.join(';') }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    form = ConversationForm.new(form_params)

    respond_to do |format|
      format.json do
        if form.save
          render json: form.conversation.as_json(only: %i[id created_at updated_at]), status: :ok
        else
          render json: {
            error: { message: form.errors.full_messages.join(';') }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def form_params
    conversation_params.merge(user: current_user)
  end

  def conversation_params
    params.require(:conversation).permit(:assistant_response, :memo_id, :text_id)
  end
end
