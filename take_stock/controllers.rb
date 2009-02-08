module TakeStock::Controllers
  class Index
    def get
      redirect (logged_in?) ? Games : Login
    end
  end

  class Games
    def get
      require_login!

      @games = @user.games
      render :games
    end
  end

  class CreateGame < R '/game/create'
    def get
      require_login!
      
      @players = []
      
      render :create_game
    end

    def post
      require_login!
      
      users = []
      invalid_names = []
      
      input.players.each do |_,name|
        next if name.empty?
        user = User.find_by_name(name)
        if user
          users << user
        else
          invalid_names << name
        end
      end
      
      if invalid_names.empty?
        game = Game.create(:name => input.name)
        users.each do |user|
          game.players.create(:user_id => user.id,
                              :joined => (user == @user) ? true : false)
        end
        
        redirect ViewGame, game
      else
        @info = "The following usernames are invalid: #{invalid_names.join(', ')}"
        @players = users.map {|user| user.name }
        render :create_game
      end
    end
  end

  class ViewGame < R '/game/(\d+)'
    def get game_id
      require_login!
      
      @game = Game.find(game_id.to_i)
      @players = @game.players
      
      p @game
      p @players

      if @game.started?
        render :view_game
      else
        render :join_game
      end
    end
  end

  class JoinGame < R '/game/join'
    def post
      require_login!
      
      game = Game.find(input.game_id)
      player = game.players.find(:first, :conditions => "user_id = #{@user.id}")
      player.joined = true
      player.save
      
      game.start! if game.started?
      
      redirect ViewGame, game
    end
  end
  
  class StartGame < R '/game/(\d+)/start'
    def get game_id
      game = Game.find(game_id)
      game.start!
      
      redirect ViewGame, game
    end
  end

  class Login
    def get
      @to = input.to
      render :login
    end

    def post
      @user = User.find_by_name(input.name)
      @to = input.to

      if @user
        @state.user_id = @user.id
        if @to
          redirect @to
        else
          redirect R(Index)
        end
      else
        @info = 'Wrong name or password'
      end

      render :login
    end
  end

  class Logout
    def get
      @state.user_id = nil
      redirect Login
    end
  end
end
