shared_examples 'an API authenticated route' do
  it 'responds with unauthorized' do
    request
    expect(response).to have_http_status :unauthorized
  end

  it 'responds with an error' do
    request
    expect(JSON.parse(response.body)).to eq({ 'error' => 'You need to sign in or sign up before continuing.' })
  end
end

shared_examples 'an authenticated route' do
  it 'redirects to sign_in' do
    sign_out :user
    request
    expect(response).to redirect_to '/users/sign_in'
  end

  it 'shows an error message' do
    sign_out :user
    request
    expect(flash[:alert]).to eq 'You need to sign in or sign up before continuing.'
  end
end
