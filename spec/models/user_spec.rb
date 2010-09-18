require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do

  it "should create a new instance given valid attributes" do
    user = Factory.build(:user)
    user.should be_valid
  end

  it "should give an error given a wrong password_confirmation" do
    user = Factory.build(:user, :password_confirmation => 'blub')
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end

  it "should require a minimum length of 4 for a password" do
    user = Factory.build(:user, :password => 'sho')
    user.should_not be_valid
    user.should have(1).error_on(:password)
  end

  it "should not allow two users with the same name" do
    user1 = Factory.create(:user, :name => 'peter')
    user2 = Factory.build(:user, :name => 'peter')
    user1.should be_valid
    user2.should_not be_valid
  end

  it "should not allow two useres with the same email" do
    user1 = Factory.create(:user, :email => 'peter@test.com')
    user2 = Factory.build(:user, :email => 'peter@test.com')
    user1.should be_valid
    user2.should_not be_valid
  end

  it "should not allow invalid email addresses" do
    invalid_emails = ['foo@bar.', 'foo@bar.de.', 'foo.de.de', '@bar.de']
    invalid_emails.each do |email|
      user = Factory.build(:user, :email => email)
      user.should_not be_valid
    end
  end

end

describe User, "to_json" do

  before(:each) do
    @user = Factory.create(:user, :name => 'peter', :email => 'peter@doc.com', :wca => '2007JDAE01')
    @user_hash = JSON.parse(@user.to_json)
    @forbidden_attributes = [:encrypted_password, :ignored, :role, :salt, :email, :created_at, :sponsor]
    @necessary_attributes = [:id, :singles_count, :time_zone, :wca, :name]
  end

  it "should not display sensible information via json" do
    @forbidden_attributes.each do |attribute|
      @user_hash['user'].keys.should_not include(attribute.to_s)
    end
  end

  it "should contain necessary informations about a user" do
    @necessary_attributes.each do |attribute|
      @user_hash['user'].keys.should include(attribute.to_s)
    end
  end

  it "should contain proper values" do
    @user_hash['user']['name'].should == 'peter'
    @user_hash['user']['singles_count'].should == 0
    @user_hash['user']['wca'].should == '2007JDAE01'
  end

end

describe User, "password" do

  before(:each) do
    @user = Factory.create(:user)
  end

  it "should flash the password after save" do
    @user.password.should be_nil
    @user.password_confirmation.should be_nil
  end

  it "should reset the password to a at least 12 characters long string"do
    @user.reset_password!
    @user.password.should =~ /[a-z0-9A-Z]{12}/
  end

end

=begin
describe User, "matches association" do

  it "should find all matches for this user" do
    user = Factory.create(:user)
    match_1 = Factory.create(:match, :user => user)
    match_2 = Factory.create(:match, :opponent => user)
    user.matches.size.should == 2
    user.matches.include?(match_1).should be_true
    user.matches.include?(match_2).should be_true
  end

end


describe User, "ranking" do

  def users(*points)
    points.each do |p|
      Factory.create(:user, :points => p)
    end
  end

  it "should rank a user with 1000 points between two other users with 500 and 1500 at rank 2" do
    users(500, 1500)
    user = Factory.create(:user, :points => 1000)
    user.rank.should == 2
  end

  it "should rank a user at rank 1 if he shares the same points as the best" do
    users(100, 400, 400)
    user = Factory.create(:user, :points => 400)
    user.rank.should == 1
  end

  it "should rank a user last if he's really last" do
    users(1000, 1500, 400)
    user = Factory.create(:user, :points => 323)
    user.rank.should == 4
  end

  it "should rank all users at place 1 if they're equally strong'" do
    users(100, 100, 100, 100)
    User.all.each do |u|
      u.rank.should == 1
    end
  end

end

describe User, "streak" do
  it "should return a +2 for two consecutive wins" do
    Factory.create(:match, :user => user, :user_points => 10, :opponent_points => 2, :status => 'finished')
    Factory.create(:match, :user => user, :user_points => 10, :opponent_points => 2, :status => 'finished')
    user.streak.should == 2
  end

  it "should return 0 for a user without any matches" do
    user.streak.should == 0
  end

  it "should return 10 for a user with 10 consecutive wins and a deuce then" do
    Match.delete_all
    user = Factory.create(:user)
    10.times do
      Factory.create(:match, :user => user, :user_points => 20, :opponent_points => 3, :status => 'finished')
    end
    Factory.create(:match, :user => user, :user_points => 3, :opponent_points => 3, :status => 'finished')
    user.streak.should == 10
  end

  it "should return 1 for a user who's opponent in a match and has a streak of 1" do
    Factory.create(:match, :opponent => user, :user_points => 4, :opponent_points => 5, :status => 'finished')
    user.streak.should == 1
  end

  it "should ignore challenged or pending matches" do
    Factory.create(:match, :opponent => user, :user_points => 3, :opponent_points => 5, :status => 'finished')
    Factory.create(:match, :opponent => user, :status => 'pending')
    Factory.create(:match, :opponent => user, :user_points => 3, :opponent_points => 5, :status => 'finished')
    Factory.create(:match, :opponent => user, :status => 'challenged')
    user.streak.should == 2
  end

  it "should return -2 for two consecutive loss" do
    Factory.create(:match, :user => user, :user_points => 2, :opponent_points => 3, :status => 'finished')
    Factory.create(:match, :user => user, :user_points => 2, :opponent_points => 6, :status => 'finished')
    user.streak.should == -2
  end

  def user
    @user ||= Factory.create(:user)
  end
end

describe User, "wins and losses" do
  it "should return 1 win and 0 losses" do
    user = Factory.create(:user)
    Factory.create(:match, :user => user, :user_points => 4, :opponent_points => 3, :status => 'finished')
    user.wins.should == 1
    user.losses.should == 0
  end
end

=end