class TranscriptionSummariesController < ApplicationController
  def create
    transcription = current_user.transcriptions.find(transcription_summary_params[:transcription_id])
    summary = transcription.create_summary

    respond_to do |format|
      format.turbo_stream do
        if summary.persisted?
          render(
            inline: turbo_stream.update(
              "transcription_summary_#{transcription.id}",
               TranscriptionSummaryComponent.new(transcription:).render_in(view_context)
            ),
            status: :created
          )
          TranscriptionSummaryJob.perform_async(current_user.id, transcription.id)
          summary.queued!
        else
          # TODO render flash messages
        end
      end
    end
  end

  private

  def transcription_summary_params
    params.require(:transcription_summary).permit(:transcription_id)
  end
end
