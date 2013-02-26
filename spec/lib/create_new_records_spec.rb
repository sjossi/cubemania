require "spec_helper"

describe CreateNewRecords do
  let(:user) { create :user }
  let(:puzzle) { create :puzzle }

  describe ".for_type" do
    let(:single_1) { create :single, :user => user, :puzzle => puzzle, :time => 10 }
    let(:single_2) { create :single, :user => user, :puzzle => puzzle, :time => 5 }
    let(:single_3) { create :single, :user => user, :puzzle => puzzle, :time => 1 }
    let(:single_4) { create :single, :user => user, :puzzle => puzzle, :time => 5 }
    let(:single_5) { create :single, :user => user, :puzzle => puzzle, :time => 5 }
    let(:singles) { [single_1, single_2, single_3, single_4, single_5] }
    let(:type) { RecordType.by_count(5) }

    context "no existing record" do
      it "creates a new record" do
        result = CreateNewRecords.for_type(user, puzzle, singles, type)
        expect(result).to be_true
        expect(Record.count).to eq(1)
        expect(Record.first.time).to eq(5)
        expect(Record.first.puzzle).to eq(puzzle)
        expect(Record.first.user).to eq(user)
        expect(Record.first.amount).to eq(5)
      end
    end

    context "existing slower record" do
      before { create :record, :user => user, :puzzle => puzzle, :time => 20 }

      it "creates a new record" do
        result = CreateNewRecords.for_type(user, puzzle, singles, type)
        expect(result).to be_true
      end
    end

    context "existing faster record" do
      before { create :record, :user => user, :puzzle => puzzle, :time => 3 }

      it "doesn't create a new record" do
        result = CreateNewRecords.for_type(user, puzzle, singles, type)
        expect(result).to be_false
        expect(Record.count).to eq(1)
      end
    end
  end

  describe ".for(user, puzzle)" do
    let(:type_1) { stub(:type, :count => 5) }
    let(:type_2) { stub(:type, :count => 12) }
    let(:types) { [type_1, type_2] }
    let(:singles) { [stub, stub, stub] }
    let(:record) { stub }

    it "runs creation of new records for each type and returns all updated records" do
      user.stub_chain(:singles, :for, :recent).and_return(singles)
      RecordType.should_receive(:all).and_return(types)
      RecordType.stub(:max_count => 12)

      CreateNewRecords.should_receive(:for_type).with(user, puzzle, singles, type_1).and_return(nil)
      CreateNewRecords.should_receive(:for_type).with(user, puzzle, singles, type_2).and_return(record)
      expect(CreateNewRecords.for(user, puzzle)).to eq [record]
    end
  end
end
