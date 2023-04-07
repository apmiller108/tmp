class UsersController < ApplicationController
  def show
    respond_to do |format|
      format.html do
        render UserComponent.new(user: current_user).with_content('Yo!'), content_type: 'text/html'
      end
      format.json { render json: current_user.as_json(only: %i[id email]) }
    end
  end
end
