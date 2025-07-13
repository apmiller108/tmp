class ConversationContextsController < ApplicationController
  before_action :set_conversation, only: [:create, :index]

  def create
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

  def index
    @contexts = @conversation.contexts.order(created_at: :desc)
    respond_to do |format|
      format.html
      format.json { render json: @contexts, status: :ok }
    end
  end

  def destroy
    @context = @conversation.contexts.find(params[:id])

    respond_to do |format|
      if @context.destroy
        format.json { head :no_content }
      else
        fomat.json do
          render json: { error: 'Unable to delete context' },
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def conversation_context_params
    params.require(:conversation_context).permit(:file)
  end
end
