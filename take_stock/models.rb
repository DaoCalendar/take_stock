module TakeStock::Models
  Stocks = {
    :cereal => 'Crispyflake Corn Cereal Co.',
    :gems => 'Gliterring Gems Ltd.',
    :tech => 'Zeta-Chip Technology Ltd.',
    :oil => 'Arctic Oil Drilling Co.',
    :movies => 'Movie Madness Distributors'
  }
  
  class User < Base
    has_many :players
    has_many :games, :through => :players

    # name
    # email
    # password
  end

  class Player < Base
    include SerializedDataAttributes
    extend SerializedDataAttributes::ClassMethods
    
    belongs_to :game
    belongs_to :user

    def name
      user.name
    end
    
    data_attr :stock_options, :shares
    
    # hand (shares)
    # stock options
    # saved market events
    # certificates
  end

  class Game < Base
    include SerializedDataAttributes
    extend SerializedDataAttributes::ClassMethods
      
    has_many :players

    def started?
      players.all? {|i| i.joined? }
    end
    
    def start!
      shares = Stocks.inject([]) do |n,(stock,_)|
        (2..12).inject(n) {|o,i| o << [stock, i]; o }
        n
      end.sort_by { rand }
    
      players.each do |player|
        player.stock_options = 4
        shares = Array.new(9 - players.size) { shares.unshift }
        shares << shares.unshift if players.size == 6
        player.shares = shares
        player.save
      end      
    end
    
    # current_player
    # current_action

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
        t.boolean :joined,  :null => false
        t.string  :data,    :default => "--- {}\n\n"
      end
      create_table :takestock_games, :force => true do |t|
        t.string :name, :null => false
        t.string  :data,    :default => "--- {}\n\n"
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
    
    def initialize(a_stock, a_value)
      @stock = a_stock
      @value = a_value
    end
  end

  class Certificate
    attr_accessor :stock, :value
  end

  class MarketEvent; end
end