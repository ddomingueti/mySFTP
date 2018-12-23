require 'xmlrpc/server'
require 'xmlrpc/client'
require 'json'
require 'mysql2'
load "../Model/ResponseCodes.rb"

class UserServer

    def initialize
        @fileServer = XMLRPC::Client.new("172.18.1.48", nil, 5678)
        @host = "localhost"
        @database = "mysftp"
        @username ="root"
        @password = ""
        @dbConnection = nil
    end


    def login(jsonData)
        puts jsonData
        @dbConnection = Mysql2::Client.new(:host => @host, :username => @username, :database => @database, :password => @password)
        hash = JSON.parse(jsonData)
        user = hash['username']
        pw = hash['password']
        statement = @dbConnection.prepare("select * from users where username = '#{user}' and password = '#{pw}'")
        res = statement.execute()
        puts res.size
        returnCode = ResponseCodes::USER_NOT_FOUND
        superUser = 0
        if (res.size > 0)
            res.each do |row|
                puts row.to_s
                superUser = row['superuser']
            end
            returnCode = ResponseCodes::SUCCESS
        end
        @dbConnection.close()
        return {:returnCode => returnCode, :superuser => superUser}.to_json
        
    end

    def addUser(jsonData)
        @dbConnection = Mysql2::Client.new(:host => @host, :username => @username, :database => @database, :password => @password)
        hash = JSON.parse(jsonData)
        user = hash['username']
        pw = hash['password']
        su = hash['superuser']
        if (su == true)
            su = 1
        else
            su = 0
        end
        
        statement = @dbConnection.prepare("INSERT INTO `users` (`id`, `username`, `password`, `superuser`) VALUES (NULL, '#{user}', '#{pw}', #{su}); ")
        result = statement.execute()
        if (result == nil)
            resp = @fileServer.call('file.mkdir', user)
            return ResponseCodes::SUCCESS
        end
        @dbConnection.close()
        return ResponseCodes::USER_EXISTS
    end

    def rmUser(user)
        @dbConnection = Mysql2::Client.new(:host => @host, :username => @username, :database => @database, :password => @password)
        statment = @dbConnection.prepare("delete from users where username = '#{user}'")
        result = statment.execute()
        if result == nil
            @fileServer.call('file.rmuser', user)
            return ResponseCodes::SUCCESS
        else
            return ResponseCodes::USER_NOT_FOUND
        end
    end

end

s = XMLRPC::Server.new(6789)
s.add_handler("user", UserServer.new)

s.set_default_handler do |name, *args|
    raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                     " or wrong number of parameters!")
  end
  
s.serve
puts "User Server running ... "