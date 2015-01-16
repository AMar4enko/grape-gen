class TokenStrategy < Warden::Strategies::Base
  def store?; false end
  def valid?
    env['HTTP_X_AUTHORIZE']
  end
  def access_token_type
    :public
  end
  def authenticate!
    user = Models::User.find_by(token: env['HTTP_X_AUTHORIZE'])

    if user.nil?
      fail!(:no_access)
    else
      success!(user)
    end
  end
end