class ConversationsController < ApplicationController
  def create
    memo = current_user.memos.find(params[:memo_id])
    conversation = memo.conversation || memo.build_conversation
    generative_text_request = current_user.generate_text_requests.find_by!(text_id: params[:text_id])

    conversation.exchange << { role: :user, content: [{ type: :text, text: generative_text_request.prompt }] }
    conversation.exchange << { role: :assistant, content: conversation_params[:assistant_response] }

    respond_to do |format|
      format.json do
        if conversation.save?
          render json: conversation.as_json(only: %i[id created_at updated_at]), status: :ok
        else
          render json: {
            error: { message: conversation.errors.full_messages.join(';') }
          }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def conversation_params
    params.require(:conversation).permit(:assistant_response)
  end
end
