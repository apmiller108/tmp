class GenerateTextRequestsController < ApplicationController
  def file
    generate_text_request = current_user.generate_text_requests.find(params[:id])
    @blob = generate_text_request.file.blob
  end
end
