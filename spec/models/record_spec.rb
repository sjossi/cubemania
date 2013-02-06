require 'spec_helper'

describe Record do
  describe "validations" do
    it { should validate_presence_of :puzzle_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :time }
    it { should validate_presence_of :amount }
    it { should validate_presence_of :singles }
    it { should validate_presence_of :set_at }

    it "has as many singles as amount" do
      record = Record.new :amount => 5, :singles => [Single.new] * 3
      record.should_not be_valid
      record.errors[:singles].should_not be_empty
    end

    describe "time" do
      before do
        create :record, :user_id => 1, :puzzle_id => 2, :amount => 5, :time => 50, :created_at => DateTime.new(2012, 11, 1)
        create :record, :user_id => 1, :puzzle_id => 2, :amount => 5, :time => 20, :created_at => DateTime.new(2012, 12, 2)
      end

      it "is not valid if the new time is slower than the last record" do
        r = build :record, :user_id => 1, :puzzle_id => 2, :time => 40
        expect(r).to_not be_valid
        expect(r.errors[:time]).to_not be_empty
      end

      it "is not valid if the new time is equal to the old record" do
        r = build :record, :user_id => 1, :puzzle_id => 2, :time => 20
        expect(r).to_not be_valid
        expect(r.errors[:time]).to_not be_empty
      end

      it "is valid if the new time is faster" do
        r = build :record, :user_id => 1, :puzzle_id => 2, :time => 19
        expect(r).to be_valid
      end

      it "keeps different record types seperate" do
        r = build :record, :user_id => 1, :puzzle_id => 2, :amount => 1, :time => 100
        expect(r).to be_valid
      end
    end
  end

  describe "#set_at" do
    it "is set to date of most recent single" do
      s = []
      s << create(:single, :created_at => Time.new(2012, 3, 1))
      s << create(:single, :created_at => Time.new(2012, 3, 4))
      s << create(:single, :created_at => Time.new(2012, 1, 8))
      s << create(:single, :created_at => Time.new(2012, 5, 2))
      s << create(:single, :created_at => Time.new(2012, 2, 2))
      record = Record.new :amount => 5, :singles => s
      record.save
      record.set_at.should == s[3].created_at
    end
  end

  describe "#singles" do
    it "defaults to an empty array" do
      subject.singles.should == []
    end

    it "orders them by singles.created_at" do
      single_old = single_new = nil
      Timecop.freeze(DateTime.new(2010, 1, 2)) do
        single_old = create :single
      end
      Timecop.freeze(DateTime.new(2011, 1, 2)) do
        single_new = create :single
      end
      single_today = create :single
      record = create :record, :singles => [single_new] + [single_today] * 3 + [single_old]
      record.singles.ordered.last.should == single_today
      record.singles.ordered.first.should == single_old
    end
  end

  describe ".grouped_by_puzzle_and_amount" do
    let(:puzzle_1) { create :puzzle }
    let(:puzzle_2) { create :puzzle }
    let!(:record_1) { create :record, :amount => 5, :puzzle => puzzle_1 }
    let!(:record_2) { create :record, :amount => 5, :puzzle => puzzle_2 }
    let!(:record_3) { create :record, :amount => 12, :puzzle => puzzle_2 }

    let(:records) { Record.grouped_by_puzzle_and_amount }

    it "groups all records by puzzle and then by amount" do
      expect(records[puzzle_1][5]).to eq(record_1)
      expect(records[puzzle_2][5]).to eq(record_2)
      expect(records[puzzle_2][12]).to eq(record_3)
    end
  end

  describe "comments" do
    let(:single_1) { create :single, :comment => "foo" }
    let(:single_2) { create :single, :comment => "muh" }
    let(:single_3) { create :single, :comment => "too long"*30 }
    let(:record) { create :record, :singles => create_list(:single, 3) + [single_1] + [single_2] }

    subject { record.comment }

    it "concatenates comments from singles" do
      should == "foo; muh"
    end

    it "cuts off too long comments without failing comment validation" do
      record = create :record, :singles => [single_1, single_2, single_3, single_1, single_2]
      record.comment.size.should be <= 255
    end

    describe "#update_comment!" do
      let(:singles) { create_list :single, 5 }

      it "fetches comments from singles and updates record object" do
        record = create :record, :singles => singles
        singles[0].should_receive(:comment).at_least(:once) { "bar" }
        singles[1].should_receive(:comment).at_least(:once) { "foo" }
        record.should_receive(:update_attributes).with(:comment => "bar; foo")
        record.update_comment!
      end
    end
  end

  describe "#scrambles" do
    let(:single_1) { build :single, :scramble => "D2 R2" }
    let(:single_2) { build :single, :scramble => "R B" }
    let(:record) { build :record, :amount => 2, :singles => [single_1, single_2] }

    it "returns all scrambles of the singles" do
      expect(record.scrambles).to eq(["D2 R2", "R B"])
    end
  end
end
