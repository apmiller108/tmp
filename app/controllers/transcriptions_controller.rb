class TranscriptionsController < ApplicationController
  def index
    transcription = current_user.transcriptions.find_by!(transcription_job_id: params[:transcription_job_id])

    respond_to do |format|
      format.turbo_stream do
        render(
          inline: turbo_stream.replace(
            "transcription_job_#{transcription.transcription_job_id}",
            TranscriptionComponent.new(transcription:).render_in(view_context)
          )
        )
      end
    end
  end
end
