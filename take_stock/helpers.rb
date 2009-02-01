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

module SerializedDataAttributes
  class << self
    def included(base)
      base.serialize :data
    end
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