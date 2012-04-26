class SinglesController < ApplicationController
  respond_to :json

  def index
    user = User.find params[:user_id]
    puzzle = Puzzle.find params[:puzzle_id]
    respond_with user.singles.for(puzzle).limit(150)
  end

  def create
    puzzle = Puzzle.find params[:puzzle_id]
    single = current_user.singles.build(params[:single].merge(:puzzle_id => puzzle.id))
    if single.save
      if UpdateRecentRecords.for(current_user, puzzle)
        response.headers["X-NewRecord"] = "true"
      end
    end
    respond_to do |format|
      format.json { render :json => single } # TODO why does respond_with not work?
    end
  end

  # TODO add case for failed destruction (e.g. when single is part of competition)
  def destroy
    puzzle = Puzzle.find params[:puzzle_id]
    single = current_user.singles.find params[:id]
    if single.destroy
      enqueue_record_job current_user, puzzle
    end
    respond_with single
  end

  def update
    puzzle = Puzzle.find params[:puzzle_id]
    single = current_user.singles.find params[:id]
    if single.update_attributes params[:single]
      enqueue_record_job current_user, puzzle # TODO only enqueue if penalty attribute is changed
    end
    respond_with single
  end

private
  def enqueue_record_job(user, puzzle)
    job = RecordCalculationJob.new(user.id, puzzle.id)
    Delayed::Job.enqueue job unless job.exists?
  end
end
