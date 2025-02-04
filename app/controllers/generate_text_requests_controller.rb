class GenerateTextRequestsController < ApplicationController
  def destroy
    generate_text_request = current_user.generate_text_requests.find(params[:id])
    generate_text_request.destroy!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [turbo_stream.remove(generate_text_request)]
      end
    end
  end

  def file
    generate_text_request = current_user.generate_text_requests.find(params[:id])
    @blob = generate_text_request.file.blob
  end
end
