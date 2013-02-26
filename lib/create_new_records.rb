class CreateNewRecords
  def self.for(user, puzzle)
    singles = user.singles.for(puzzle).recent(RecordType.max_count)

    RecordType.all.map do |t|
      self.for_type user, puzzle, singles[0..(t.count - 1)], t
    end.compact
  end

  def self.for_type(user, puzzle, singles, type)
    time = type.calculator.new(singles).result

    r = Record.new :user => user,
                   :puzzle => puzzle,
                   :time => time,
                   :singles => singles,
                   :amount => type.count,
                   :latest => true
    r if r.save
  end
end
