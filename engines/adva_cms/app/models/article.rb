class Article < Content
=begin
  class Jail < Safemode::Jail
    allow :title, :full_permalink, :excerpt_html, :body_html, :published_at,
          :section, :categories, :tags, :approved_comments, :accept_comments?,
          :comments_count, :has_excerpt?
  end
=end

  filters_attributes :except => [:excerpt, :excerpt_html, :body, :body_html, :cached_tag_list]
  write_inheritable_attribute :default_find_options, { :order => 'contents.published_at desc' }

  before_create :set_position

  class << self
    def find_by_permalink(*args)
      options = args.extract_options!
      if args.size > 1
        permalink = args.pop
        with_time_delta(*args) do find_by_permalink(permalink, options) end
      else
        find :first, options.merge(:conditions => ['permalink = ?', args.first])
      end
    end
  end

  def full_permalink
    raise "can not create full_permalink for an article that belongs to a non-blog section" unless section.is_a? Blog
    # raise "can not create full_permalink for an unpublished article" unless published?
    date = [:year, :month, :day].map { |key| [key, (published? ? published_at : created_at).send(key)] }.flatten
    Hash[:permalink, permalink, *date]
  end

  def primary?
    section.articles.primary == self
  end

  def has_excerpt?
    !excerpt.blank?
  end

  def published_month
    Time.local published_at.year, published_at.month, 1
  end

  def draft?
    published_at.nil?
  end

  def pending?
    !published?
  end

  def published?
    !published_at.nil? and published_at <= Time.zone.now
  end

  def published_at?(date)
    published? and date == [:year, :month, :day].map {|key| published_at.send(key).to_s }
  end

  def state
    pending? ? :pending : :published
  end
  
  def just_published?
    published? and published_at_changed?
  end

  def previous
    section.articles.find_published :first, :conditions => ['published_at < ?', published_at], :order => :published_at
  end

  def next
    section.articles.find_published :first, :conditions => ['published_at > ?', published_at], :order => :published_at
  end

  protected

    def set_position
      self.position ||= section.articles.maximum(:position).to_i + 1 if section
    end
end
