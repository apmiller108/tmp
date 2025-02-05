class ConversationsController < ApplicationController
  layout 'conversations', except: :index
  layout 'application', only: :index

  before_action :set_conversation, only: %i[update destroy]
  before_action :verify_user_id, only: %i[create update]

  def index
    relation = current_user.conversations
    relation = relation.where(memo_id: search_params[:q][:memo_id]) if search_params.dig(:q, :memo_id)
    @conversations, @cursor = Paginate.call(relation:, limit: 10, cursor: params[:c], order: { updated_at: :desc })

    respond_to do |format|
      format.html
      format.turbo_stream
      format.json do
        render json: @conversations.as_json(only: %i[id created_at updated_at]), status: :ok
      end
    end
  end

  def new
    @conversation = current_user.conversations.new
  end

  def create
    conversation = current_user.conversations.new(
      conversation_params.merge(
        title: Conversation.title_from_prompt(prompt)
      )
    )
    respond_to do |format|
      if conversation.save
        enqueue_generate_text_job(conversation.generate_text_requests.created.last)
        format.turbo_stream do
          redirect_to edit_user_conversation_path(current_user, conversation), status: :see_other
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: t('conversation.name'))
          flash_component = FlashMessageComponent.new(flash:, record: conversation)

          render turbo_stream: [
                   turbo_stream.update(flash_component.id, flash_component),
                   turbo_stream.replace(
                     'prompt-form',
                     PromptFormComponent.new(conversation:).render_in(view_context)
                   )
                 ],
                 status: :unprocessable_entity
        end
      end
    end
  end

  def edit
    @conversation = current_user.conversations
                                .includes(generate_text_requests: :generate_text_preset)
                                .find(params[:id])
  end

  def update
    respond_to do |format|
      if @conversation.update(conversation_params)
        generate_text_request = @conversation.generate_text_requests.created.last
        enqueue_generate_text_job(generate_text_request)
        format.turbo_stream do
          render 'conversations/update',
                 locals: { conversation: @conversation, generate_text_request: },
                 status: :ok
        end
        format.json do
          render json: @conversation.as_json(only: %i[id memo_id created_at updated_at]), status: :ok
        end
      else
        format.turbo_stream do
          flash.now.alert = t('unable_to_save', model_name: t('conversation.name'))
          flash_component = FlashMessageComponent.new(flash:, record: @conversation)

          render turbo_stream: [turbo_stream.update(flash_component.id, flash_component)],
                 status: :unprocessable_entity
        end
        format.json do
          render json: { error: { message: @conversation.errors.full_messages.join(';') } },
                 status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @conversation.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@conversation)
      end
      format.html { redirect_to user_conversations_path(current_user), notice: 'Conversation deleted' }
    end
  end

  private

  def enqueue_generate_text_job(generate_text_request)
    return unless generate_text_request

    GenerateTextJob.perform_async(generate_text_request.id)
  end

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def verify_user_id
    return if generate_text_requests_attributes.nil?

    generate_text_requests_attributes.each_value do |attributes|
      raise 'Invalid user_id' if attributes[:user_id] != current_user.id.to_s
    end
  end

  def prompt
    generate_text_requests_attributes['0'][:prompt]
  end

  def generate_text_requests_attributes
    conversation_params[:generate_text_requests_attributes]
  end

  def search_params
    params.permit(q: %i[memo_id])
  end

  def conversation_params
    params.require(:conversation).permit(
      :title, :memo_id, generate_text_requests_attributes: [
        :prompt, :text_id, :temperature, :generate_text_preset_id, :conversation_id, :user_id, :model, :file
      ]
    )
  end
end
