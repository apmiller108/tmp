class ConversationContextsController < ApplicationController
  def create
    @conversation = current_user.conversations.find(params[:conversation_id])
    file_response = Anthropic.upload_file(conversation_context_params[:file])
    # TODO: create conversation context
  end

  private

  def conversation_context_params
    params.require(:conversation_context).permit(:file)
  end
end
