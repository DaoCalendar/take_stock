module TakeStock::Models
  class User < Base
    has_many :players
    has_many :games, :through => :players

    # name
    # email
    # password
  end

  class Player < Base
    belongs_to :game
    belongs_to :user

    # joined?

    # hand (shares)
    # stock options
    # saved market events
    # certificates
  end

  class Game < Base
    has_many :players

    # name
    # started?

    # round
    # shares
    #   deck
    #   discard
    # market events
    #   deck
    #   discard
    # stock market
    #   Cereal
    #   Gems
    #   Technology
    #   Oil
    #   Movie
  end

  class Setup < V 0.1
    def self.up
      create_table :takestock_users, :force => true do |t|
        t.string :name, :null => false
      end
      create_table :takestock_players, :force => true do |t|
        t.integer :user_id, :null => false
        t.integer :game_id, :null => false
        t.string  :data,    :null => false
      end
      create_table :takestock_games, :force => true do |t|
        t.string :name, :null => false
        t.string :data
      end
      User.create :name => 'alpha'
      User.create :name => 'roshan'
    end
    def self.down
      drop_table :takestock_users
      drop_table :takestock_players
      drop_table :takestock_games
    end
  end

  class Stock
    attr_accessor :splits, :shares
  end

  class Share
    attr_accessor :stock, :value
  end

  class Certificate
    attr_accessor :stock, :value
  end

  class MarketEvent; end
end