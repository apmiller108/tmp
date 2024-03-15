require 'system_helper'

RSpec.describe 'Memo show', type: :system do
  let!(:user) { create :user }

  specify 'View memo' do
    login(user:)
    # new memo
    # generate image (stub 3rd party response with base64 encoded test image)
    # save
    # view show
    # view more info
    # verify gen image details show
  end
end
