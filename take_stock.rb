require 'camping'
require 'camping/ar'
require 'camping/session'

Camping.goes :TakeStock

require 'take_stock/models'
require 'take_stock/controllers'
require 'take_stock/views'
require 'take_stock/helpers'

module TakeStock
  include Camping::Session
end

def TakeStock.create
  TakeStock::Models.create_schema :assume => (TakeStock::Models::User.table_exists? ? 1.0 : 0.0)
end
