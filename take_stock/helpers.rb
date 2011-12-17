module TakeStock
  Stocks = {
    :cereal => 'Crispyflake Corn Cereal Co.',
    :gems => 'Gliterring Gems Ltd.',
    :tech => 'Zeta-Chip Technology Ltd.',
    :oil => 'Arctic Oil Drilling Co.',
    :movies => 'Movie Madness Distributors'
  }
end

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

module TakeStock::Models
  module SerializedDataAttributes
    class << self
      def included(base)
        base.serialize :data, Hash
      end
    end

    def data
      read_attribute(:data) || write_attribute(:data, Hash.new)
    end

    module ClassMethods
      def data_attr_reader *attributes
        attributes.each do |attribute|
          class_eval "def #{attribute}; data[:#{attribute}]; end"
        end
      end
      def data_attr_writer *attributes
        attributes.each do |attribute|
          class_eval "def #{attribute}=(value); data[:#{attribute}] = value; end"
        end
      end
      def data_attr *attributes
        data_attr_reader *attributes
        data_attr_writer *attributes
      end
    end
  end
end