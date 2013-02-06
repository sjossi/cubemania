class CreateNewRecords
  def self.for(user, puzzle)
    singles = user.singles.for(puzzle).recent(RecordType.max_count)

    RecordType.all.any? do |t|
      self.for_type user, puzzle, singles[0..(t.count - 1)], t
    end
  end

  def self.for_type(user, puzzle, singles, type)
    time = type.calculator.new(singles).result

    r = Record.new :user => user,
                   :puzzle => puzzle,
                   :time => time,
                   :singles => singles,
                   :amount => type.count
    r.save
  end
end
