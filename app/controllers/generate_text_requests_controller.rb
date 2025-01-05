class GenerateTextRequestsController < ApplicationController
  def create
    generatate_text_request = current_user.generate_text_requests.create(generate_text_request_params)

    respond_to do |format|
      format.turbo_stream do
        if generatate_text_request.persisted?
          create_conversation(generatate_text_request) if generatate_text_request.conversation_id.nil?
          GenerateTextJob.perform_async(generatate_text_request.id)
          render(
            turbo_stream: [
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(prompt_to_turn).render_in(view_context)
              ),
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(pending_response_turn, pending: true).render_in(view_context)
              ),
              turbo_stream.replace(
                'prompt-form',
                PromptFormComponent.new(
                  generate_text_request: new_generate_text_request(generatate_text_request),
                  show_options:
                ).render_in(view_context)
              )
            ],
            status: :created
          )
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:, record: generatate_text_request)

          render turbo_stream: [
                   turbo_stream.update(flash_component.id, flash_component),
                   turbo_stream.replace(
                     'prompt-form',
                     PromptFormComponent.new(generate_text_request:, show_options:).render_in(view_context)
                   )
                 ],
                 status: :unprocessable_entity
        end
      end
    end
  end

  private

  def prompt_to_turn
    Conversation::Turn.for_prompt(generate_text_request_params[:prompt])
  end

  def pending_response_turn
    Conversation::Turn.for_response('')
  end

  def new_generate_text_request(generate_text_request)
    current_user.generate_text_requests.new(
      generate_text_request.slice(:temperature, :generate_text_preset_id, :conversation_id, :model)
    )
  end

  def show_options
    ActiveModel::Type::Boolean.new.cast(params[:show_options].downcase)
  end

  def create_conversation(generate_text_request)
    generate_text_request.update(
      conversation: Conversation.create!(
        title: generate_text_request.prompt.truncate(35),
        user: current_user
      )
    )
  end

  def generate_text_request_params
    params.require(:generate_text_request).permit(
      :prompt, :text_id, :temperature, :generate_text_preset_id, :conversation_id, :model
    )
  end
end
