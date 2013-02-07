class Puzzle < ActiveRecord::Base
  extend FriendlyId

  FORMATS = %w{average mean best_of}

  friendly_id :full_name, :use => :slugged

  after_save :compose_fb_image

  belongs_to :kind
  has_many :competitions, :dependent => :destroy
  has_many :singles, :dependent => :destroy
  has_many :records, :order => "records.time", :include => :user, :conditions => { 'users.ignored' => false }, :dependent => :destroy do
    def amount(n) # TODO move to Record
      where(:amount => n)
    end
  end

  validates_presence_of :name, :attempt_count, :countdown, :kind_id
  validates_length_of :name, :maximum => 64
  validates_numericality_of :scramble_length, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 255, :only_integer => true
  validates_numericality_of :countdown, :greater_than_or_equal_to => 0, :only_integer => true
  validates_numericality_of :attempt_count, :greater_than => 0, :only_integer => true
  validates_inclusion_of :average_format, :in => FORMATS
  validates_uniqueness_of :name, :scope => :kind_id

  def self.default
    where('puzzles.name' => '3x3x3').joins(:kind).where('kinds.name' => 'speed').first
  end

  def scrambles
    (1..attempt_count).map { |i| scramble }
  end

  def full_name
    if kind.short_name.blank?
      name
    else
      "#{name} #{kind.short_name}"
    end
  end

  def combined_file_name
    "#{slug}.png"
  end

  def combined_url(bucket = Rails.application.config.s3_bucket)
    "http://s3.amazonaws.com/#{bucket}/puzzles/#{combined_file_name}?#{updated_at.to_i}"
  end

  def scramble
    case name.downcase
      when '2x2x2'
        Scrambler::TwoByTwo.new.scramble(scramble_length)
      when '3x3x3'
        Scrambler::ThreeByThree.new.scramble(scramble_length)
      when '4x4x4'
        Scrambler::FourByFour.new.scramble(scramble_length)
      when '5x5x5'
        Scrambler::FiveByFive.new.scramble(scramble_length)
      when '6x6x6'
        Scrambler::SixBySix.new.scramble(scramble_length)
      when '7x7x7'
        Scrambler::SevenBySeven.new.scramble(scramble_length)
      when 'megaminx'
        Scrambler::Megaminx.new.scramble(scramble_length)
      when 'pyraminx'
        Scrambler::Pyraminx.new.scramble(scramble_length)
      when 'square-1'
        Scrambler::Square1.new.scramble(scramble_length)
      when 'clock'
        Scrambler::Clock.new.scramble(scramble_length)
      else
        ''
    end.html_safe
  end

  private
  def compose_fb_image
    unless Rails.env.test?
      temp_file = Tempfile.new("temp.png")
      puzzles_path = Rails.root.join("app", "assets", "images", "puzzles.png")
      kinds_path = Rails.root.join("app", "assets", "images", "kinds.png")
      `convert \\( #{puzzles_path} -crop 50x50+#{css_position*50}+0  \\) \\( #{kinds_path} -crop 25x25+#{kind.css_position*25}+0 \\) -gravity SouthEast -composite #{temp_file.path}`
      AWS::S3::S3Object.store("puzzles/#{combined_file_name}",
                              open(temp_file.path),
                              Rails.application.config.s3_bucket,
                              :access => :public_read)
    end
  end
end
