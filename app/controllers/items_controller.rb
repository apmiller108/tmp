class ItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    @items = Item.all
    respond_to do |format|
      format.html
      format.json { render json: @items }
    end
  end

  #
  # @example
  #   def index
  #     @items = Item.all
  #     respond_to do |format|
  #       format.html
  #       format.json { render json: @items }
  #     end
  #   end
  #
  # @example
  #   # spec/controllers/items_controller_spec.rb
  #   require 'rails_helper'
  #
  #   RSpec.describe ItemsController, type: :controller do
  #     describe 'GET #index' do
  #       it 'returns http success' do
  #         get :index
  #         expect(response).to have_http_status(:success)
  #       end
  #     end
  #   end
  #
  # @example
  #   # spec/requests/items_spec.rb
  #   require 'rails_helper'
  #
  #   RSpec.describe 'Items', type: :request do
  #     describe 'GET /items' do
  #       it 'returns http success' do
  #         get '/items'
  #         expect(response).to have_http_status(:success)
  #       end
  #     endend
end
