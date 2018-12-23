require 'json'

class User
    attr_accessor:username
    attr_accessor:password
    attr_accessor:superuser

    def initialize(login, password)
        @username, @password = login, password
        @superuser = false
    end

    def login(conn)
        conn.puts(self.to_json)
        response = conn.gets.chomp
        return response
    end

    def to_json
        hash = {:username => @username, :password => @password, :superuser => @superuser}
        return hash.to_json
    end
end