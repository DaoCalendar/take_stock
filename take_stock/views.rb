module TakeStock::Views
  def layout
    html do
      head do
        title 'Take Stock'
      end
      body do
        h1 { a 'Take Stock', :href => R(Index) }
        div.wrapper! do
          text yield
        end
        p.footer! do
          if logged_in?
            ul do
              li { a 'Games', :href => R(Games) }
              li { a 'Logout', :href => R(Logout) }
            end
          end
        end
      end
    end
  end

  def games
    h2 'Games'
    ul do
      @games.each do |game|
        li { a game.name, :href => R(ViewGame, game) }
      end
    end
    a 'Create new game', :href => R(CreateGame)
  end

  def create_game
    h2 'Create Game'
    p.info @info if @info

    form :action => R(CreateGame), :method => 'post' do
      label 'name', :for => 'name'
      input :name => 'name', :id => 'name'

      label 'Player 1', :for => 'players[1]'
      input :name => 'players[1]', :id => 'players[1]',
            :value => @user.name, :readonly => true

      (2..5).each do |i|
        label "Player #{i}", :for => "players[#{i}]"
        input :name => "players[#{i}]", :id => "players[#{i}]",
              :value => @players[i]
      end

      input :type => 'submit', :class => 'submit', :value => 'Create Game'
    end
  end

  def join_game
    h2 @game.name

    h3 'Waiting for players'

    table do
      @players.each do |player|
        tr do
          td player.name
          if player.joined
            td 'Joined'
          else
            if player.user == @user
              td do
                form :action => R(JoinGame), :method => 'post' do
                  input :type => 'hidden', :name => 'game_id', :value => @game.id
                  input :type => 'submit', :name => 'submit', :value => 'Join game'
                end
              end
            else
              td 'Waiting'
            end
          end
        end
      end
    end
  end

  def view_game
    h2 @game.name

    ul do
      @players.each do |player|
        li player.name
      end
    end
  end

  def login
    h2 'Login'
    p.info @info if @info

    form :action => R(Login), :method => 'post' do
      input :name => 'to', :type => 'hidden', :value => @to if @to

      label 'name', :for => 'name'
      input :name => 'name', :id => 'name'

      input :type => 'submit', :class => 'submit', :value => 'Login'
    end
  end
end