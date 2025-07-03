class ConversationContextsController < ApplicationController
  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    file_response = Anthropic.upload_file(conversation_context_params[:file])
    context = ConversationContext.create_for(@conversation, file_response)

    respond_to do |format|
      if context.persisted?
        format.json { render json: context, status: :created }
      else
        format.json { render json: context.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def conversation_context_params
    params.require(:conversation_context).permit(:file)
  end
end
