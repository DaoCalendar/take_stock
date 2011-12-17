module TakeStock::Models
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

    data_attr :stock_options, :shares

    def name
      user.name
    end

    # hand (shares)
    # stock options
    # saved market events
    # certificates
  end

  class Game < Base
    include SerializedDataAttributes
    extend SerializedDataAttributes::ClassMethods

    has_many :players

    data_attr :shares_draw_pile, :shares_discard_pile
    data_attr :events_draw_pile, :events_discard_pile
    data_attr :stocks

    def started?
      players.all? {|i| i.joined? }
    end

    def start!
      players.each do |player|
        player.stock_options = 4
      end

      prepare_stock_shares!
      generate_market_events!
      prepare_market_events!
    end

    def prepare_stock_shares!
      shares_draw_pile = []

      # prepare stock starter cards
      self.stocks = TakeStock::Stocks.inject([]) do |n,(stock,_)|
        n << { :stock => stock, :market_values => [1], :splits => 0 }
        n
      end

      # create share deck
      TakeStock::Stocks.each do |stock,_|
        (2..12).each {|i| shares_draw_pile << [stock, i] }
      end
      shares_draw_pile = shares_draw_pile.sort_by { rand }

      # deal out hand to players
      players.each do |player|
        player.shares = Array.new(9 - players.length) { shares_draw_pile.shift }
        player.shares << shares_draw_pile.shift if players.size == 6
        player.save
      end

      self.shares_draw_pile = shares_draw_pile
      self.shares_discard_pile = []
      save
    end

    def generate_market_events!
      events_draw_pile = []

      # create event deck
      TakeStock::MarketEvents.each do |market_event|
        market_event.total.times do
          if market_event.per_stock?
            TakeStock::Stocks.each do |stock,_|
              events_draw_pile << market_event.new(:game_id => id, :stock => stock)
            end
          else
            events_draw_pile << market_event.new(:game_id => id)
          end
        end
      end
      events_draw_pile = events_draw_pile.sort_by { rand }

      self.events_draw_pile = events_draw_pile
      self.events_discard_pile = []
      save
    end

    def prepare_market_events!
      # place market closed event 10th from the bottom
      market_closed, events_draw_pile = self.events_draw_pile.partition {|event| event.class == TakeStock::MarketClosed }

      self.events_draw_pile = events_draw_pile[0, events_draw_pile.length - 10] +
                              market_closed +
                              events_draw_pile[-10, 10]
      save
    end

    # current_player
    # current_action
    # round
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
        t.string  :data
      end
      create_table :takestock_games, :force => true do |t|
        t.string  :name,  :null => false
        t.string  :data
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