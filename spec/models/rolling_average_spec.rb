require 'spec_helper'

describe RollingAverage do
  it "should return nil for an invalid average" do
    average = RollingAverage.new(5)
    average << Single.new(:time => 2)
    average << Single.new(:time => 4)
    average << Single.new(:time => 1)
    average << Single.new(:time => 3)
    average.average.should == 2.5
    average << Single.new(:time => 4)
    average.average.should == 3
    average << Single.new(:time => 0)
    ("%.2f" % average.average).should == "2.67"
    average << Single.new(:time => 2, :dnf => true)
    ("%.2f" % average.average).should == "2.67"
    average << Single.new(:time => 10, :dnf => true)
    average.average.should be_nil
    average << Single.new(:time => 4)
    average << Single.new(:time => 3)
    average << Single.new(:time => 2)
    average << Single.new(:time => 5)
    average.average.should == 4
    average << Single.new(:time => 2)
    average.average.should == 3
  end
end
