module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = request.env['warden'].user
      return reject_unauthorized_connection if current_user.blank?
    end
  end
end
