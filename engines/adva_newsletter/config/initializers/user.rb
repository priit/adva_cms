ActionController::Dispatcher.to_prepare do
  User.class_eval do
    has_many :subscriptions, :dependent => :destroy, :class_name => "Adva::Subscription"
    accepts_nested_attributes_for :subscriptions
  end

  UserController.class_eval do
    before_filter :set_newsletter_attributes, :only => :new

    protected

      def set_newsletter_attributes
        @newsletters = @site.newsletters.published
        @newsletter_attributes = []
        @newsletters.each do |newsletter|
          attributes = {}
          attributes["subscribable_id"]   = newsletter.id
          attributes["subscribable_type"] = newsletter.class.to_s
          @newsletter_attributes << attributes
        end
      end
  end
end

class UserFormBuilder < ExtensibleFormBuilder
  after :user, :default_fields do |f|
    render "adva/subscriptions/signup", :f => f
  end
end
