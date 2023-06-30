module AuthHeader
  def auth_headers(user)
    post('/users/sign_in.json', params: { user: { email: user.email, password: user.password } })
    bearer_token = response.headers['Authorization']
    {
      'Authorization' => bearer_token,
      'Content-Type' => 'application/json'
    }
  end
end
