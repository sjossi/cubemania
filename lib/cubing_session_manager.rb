class CubingSessionManager
  def self.create_or_add(single, session_class=CubingSession)
    current_session = session_class.last_for(single.user_id, single.puzzle_id)

    if current_session.nil? or current_session.too_old?(single)
      session_class.create_from_single single
    else
      current_session.add_single!(single)
      current_session
    end
  end
end
