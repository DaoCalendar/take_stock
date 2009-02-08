require 'camping'
require 'camping/ar'
require 'camping/session'

Camping.goes :TakeStock

require 'take_stock/market_events'
require 'take_stock/helpers'
require 'take_stock/models'
require 'take_stock/controllers'
require 'take_stock/views'

module TakeStock
  include Camping::Session
end

def TakeStock.create
  TakeStock::Models.create_schema :assume => (TakeStock::Models::User.table_exists? ? 1.0 : 0.0)
end
