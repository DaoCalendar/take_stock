module TakeStock::Helpers
  def logged_in?
    !!@state.user_id
  end

  def require_login!
    unless logged_in?
      redirect X::Login, :to => @env.REQUEST_URI
      throw :halt
    end

    @user = TakeStock::Models::User.find(@state.user_id)
  end
end