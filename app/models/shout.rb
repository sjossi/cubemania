class Shout < ActiveRecord::Base
  belongs_to :user
  belongs_to :competition

  attr_accessible :content

  validates_presence_of :content, :user_id, :competition_id
end
