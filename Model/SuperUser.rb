require 'json'

class SuperUser < User
    
    def initialize(login, password)
        @login, @password = login, password
        @connToServer = nil
    end
    
    def login(conn)
        conn.puts(self.to_json)
        response = conn.gets.chomp
        if response.to_s == 'true'
            return true
        else
            return false
        end
    end
end