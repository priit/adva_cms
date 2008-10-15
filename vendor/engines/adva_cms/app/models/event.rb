class Event
  cattr_accessor :observers
  @@observers = []
  
  attr_reader :type        # what happened
  attr_reader :object      # the object that the event is about, e.g. payment
  attr_reader :source      # the origin or the event, e.g. payment processor

  class << self
    def trigger(type, object, source)
      event = Event.new type, object, source
      observers.each do |observer| 
        callback = :"handle_#{event.type}!" 
        if observer.respond_to? callback
          observer.send callback, event 
        elsif observer.respond_to? :handle_event!
          observer.handle_event! event 
        end
      end
    end
  end

  def initialize(type, object, source)
    @type, @object, @source = type, object, source
  end
end