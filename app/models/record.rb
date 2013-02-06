class Record < ActiveRecord::Base
  extend Humanizeable

  belongs_to :puzzle
  belongs_to :user, :touch => true
  has_and_belongs_to_many :singles do
    def ordered
      order("singles.created_at")
    end
  end

  validates_presence_of :user_id, :puzzle_id, :time, :amount, :singles, :set_at
  validates_inclusion_of :amount, :in => RecordType.counts
  validates_length_of :comment, :maximum => 255
  validate :has_as_many_singles_as_amount
  validate :is_faster_than_old_record

  before_validation :set_set_at, :set_comments_from_singles

  humanize :time => :time

  def self.grouped_by_puzzle_and_amount
    grouped_by_puzzles = all.group_by { |r| r.puzzle }
    grouped_by_puzzles.merge(grouped_by_puzzles) { |k, v| v = v.group_by { |r| r.amount }; v.merge(v) { |k, v| v.try(:first) } }
  end

  def type
    RecordType.by_count amount
  end

  def scrambles
    singles.map(&:scramble)
  end

  def update_comment!
    update_attributes :comment => comments_from_singles
  end

  private
  def has_as_many_singles_as_amount
    errors.add(:singles, "must have #{amount} items, but has #{singles.size}") if singles && singles.size != amount
  end

  def set_set_at
    unless singles.empty?
      self.set_at = singles.sort_by { |s| s.created_at }.last.created_at || Time.now
    end
  end

  def comments_from_singles
    singles.map(&:comment).uniq.reject(&:blank?).join("; ")[0..254]
  end

  def set_comments_from_singles
    self.comment = comments_from_singles
  end

  def is_faster_than_old_record
    last_record = Record.where(:user_id => user_id, :puzzle_id => puzzle_id, :amount => amount).order("created_at desc").first # TODO extract method
    errors.add(:time, "must be faster than old record") if last_record && last_record.time <= time
  end
end
