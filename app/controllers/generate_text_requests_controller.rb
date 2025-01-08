class GenerateTextRequestsController < ApplicationController
  def create
    generate_text_request = current_user.generate_text_requests.create(generate_text_request_params)

    respond_to do |format|
      format.turbo_stream do
        if generate_text_request.persisted?
          create_conversation(generate_text_request) if generate_text_request.conversation_id.nil?
          GenerateTextJob.perform_async(generate_text_request.id)
          render(
            turbo_stream: [
              turbo_stream.append(
                'conversation-turns',
                ConversationTurnComponent.new(generate_text_request:).render_in(view_context)
              ),
              turbo_stream.replace(
                'prompt-form',
                PromptFormComponent.new(
                  generate_text_request: new_generate_text_request(generate_text_request),
                  show_options:,
                  disabled: true
                ).render_in(view_context)
              )
            ],
            status: :created
          )
        else
          flash.now.alert = t('unable_to_generate_text')
          flash_component = FlashMessageComponent.new(flash:, record: generate_text_request)

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

  def new_generate_text_request(generate_text_request)
    current_user.generate_text_requests.new(
      generate_text_request.slice(:temperature, :generate_text_preset_id, :conversation_id, :model)
    )
  end

  def show_options
    ActiveModel::Type::Boolean.new.cast(params[:show_options].downcase) if params[:show_options]
  end

  def create_conversation(generate_text_request)
    generate_text_request.update(
      conversation: Conversation.create!(
        title: generate_text_request.prompt.truncate(40, separator: ' '),
        user: current_user
      )
    )
  end

  def generate_text_request_params
    params.require(:generate_text_request).permit(
      :prompt, :text_id, :temperature, :generate_text_preset_id, :conversation_id, :model
    ).reverse_merge(model: current_user.setting.text_model)
  end
end
