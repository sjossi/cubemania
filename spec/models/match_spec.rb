require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Match, "validation and security" do
  before(:each) do
  end

  it "should be valid given valid attributes" do
    match = Factory.build(:match)
    match.should be_valid
  end
  
  it "should not be valid missing a user" do
    match = Factory.build(:match, :user => nil)
    match.should_not be_valid
    match.errors.on(:user_id).should =~ /blank/
  end
  
  it "should not be valid missing an opponent" do
    match = Factory.build(:match, :opponent => nil)
    match.should_not be_valid
    match.errors.on(:opponent_id).should =~ /blank/
  end
  
  it "should not be valid missing a puzzle" do
    match = Factory.build(:match, :puzzle => nil)
    match.should_not be_valid
    match.errors.on(:puzzle_id).should =~ /blank/
  end
  
  it "should not change the user through mass assignment" do
    match = Match.new({:user_id => 2})
    match.user_id.should be_nil
    match = Match.new({:user => Factory.build(:user)})
    match.user.should be_nil
  end
  
  it "should not allow users to challenge themselves" do
    user = Factory.create(:user)
    match = Factory.build(:match, :user => user, :opponent => user)
    match.should_not be_valid
  end
end

describe Match, "scrambles" do
  it "should save 5 scrambles for a 3x3x3 match" do
    match = Factory.create(:match, :puzzle => Factory.create(:puzzle, :attempt_count => 5))
    match = Match.find match.id
    match.scrambles.size.should == 5
  end
end

describe Match, "status" do
  before(:each) do
    @user = Factory.create(:user)
    @opponent = Factory.create(:user)
    Clock.destroy_all
  end
  
  it "should have status 'pending' after creation" do
    match = Factory.create(:match)
    match.should be_pending
    match.should_not be_finished
    match.should_not be_challenged
  end
  
  it "should have status 'challenged' after user has submitted his time" do
    match = Factory.create(:match, :user => @user)
    Factory.create(:average, :user => @user, :match => match)
    match.should be_challenged
    match.should_not be_finished
    match.should_not be_pending
  end
  
  it "should have status 'finished' after both users has submitted their times" do
    match = Factory.create(:match, :user => @user, :opponent => @opponent)
    Factory.create(:average, :user => @user, :match => match)
    Factory.create(:average, :user => @opponent, :match => match)
    match.should be_finished
    match.should_not be_pending
    match.should_not be_challenged
  end
end