module Memos
  class AutosavesController < ApplicationController
    def create
      memo = current_user.memos.create(memo_params)

      respond_to do |format|
        if memo.persisted?
          format.turbo_stream do
            render(
              turbo_stream: [
                turbo_stream.replace('new_memo', MemoFormComponent.new(memo:).render_in(view_context)),
                turbo_stream.prepend('memos', MemoCardComponent.new(memo:).render_in(view_context))
              ],
              status: :created
            )
          end
        else
          format.any do
            head :unprocessable_entity
          end
        end
      end
    end

    def update
      memo = current_user.memos.find_by(id: params[:memo_id])

      respond_to do |format|
        if memo&.update(memo_params)
          component = MemoCardComponent.new(memo:)
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(component.id, component.render_in(view_context)),
                   status: :ok
          end
        else
          format.any do
            head :unprocessable_entity
          end
        end
      end
    end

    private

    def memo_params
      params.require(:memo).permit(:content, :title, :color)
    end
  end
end
