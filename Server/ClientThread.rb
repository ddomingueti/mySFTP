load '../Model/SuperUser.rb'
load '../Model/User.rb'
load '../Model/ResponseCodes.rb'
require 'json'
require "xmlrpc/client"
require 'base64'

class ClientThread

    def initialize (connClient, clientAddr)
        @connToClient = connClient #client socket
        @clientAddr = clientAddr #client socket address
        @user = nil #current user
        @isConnected = false 
        @fileServer = XMLRPC::Client.new("127.0.0.1", nil, 5678) #fileServer connection
        @userServer = XMLRPC::Client.new("127.0.0.1", nil, 6789) #userServer connection
    end

    def viewLoop()
        while @isConnected
           # puts "waiting for user input ..."
            cmd = @connToClient.gets.chomp
           # puts "Recv : " + cmd
            case cmd
            when "ls"
                ls()
            when "put"
                put()
            when "get"
                get()
            when "cd"
                cd()
            when "mkdir"
                mkdir()
            when "useradd"
                addUser()
            when "userrm"
                rmUser()
            when "quit"
                @isConnected = false
            end
        end
        @connToClient.close()
    end

    def ls()
        path = @connToClient.gets.chomp
        response = @fileServer.call("file.ls", path)
        @connToClient.puts response.to_json
    end
    
    def put()
        fileName = @connToClient.gets.chomp
        @connToClient.send([1].pack("I"), 0)
        recvSize = @connToClient.recv(4)
        size = recvSize.unpack("I")
        @connToClient.send([1].pack("I"), 0)
        data = ""
        recvSize = 0
        while (recvSize < size[0])
            chunkSize = @connToClient.recv(4) 
            chunkSize = chunkSize.unpack("I")
            parcialData = @connToClient.recv(chunkSize[0])
            data << parcialData
            recvSize += chunkSize[0]
            @connToClient.send([1].pack("I"), 0)
        end
        data = Base64.encode64(data)
        response = @fileServer.call("file.put", fileName, data)
        @connToClient.send([response].pack("I"), 0)
    end

    def get()
        fileName = @connToClient.gets.chomp
        response = @fileServer.call("file.get", fileName)
        @connToClient.send([response[0]].pack("I"), 0)
        
        if (response[0] == ResponseCodes::SUCCESS)
            data = Base64.decode64(response[1])
            @connToClient.send([data.length].pack("I"), 0)
            ack = @connToClient.recv(4)
            sendSize = 0
            while (sendSize < data.length)
                amount = if data.length - sendSize > 1024 then 1024 else data.length - sendSize end
                if (sendSize != 0)
                    @connToClient.send(data[sendSize+1..sendSize + amount+1], 0)
                else
                    @connToClient.send(data[sendSize..sendSize + amount], 0)
                end
                sendSize += amount
                ack = @connToClient.recv(4)
            end
        end
    end
    
    def cd ()
        dirName = @connToClient.gets.chomp
        response = @fileServer.call("file.cd", dirName)
        @connToClient.send([response].pack("I"), 0)
    end

    def mkdir()
        dirName = @connToClient.gets.chomp
        response = @fileServer.call("file.mkdir", dirName)
        @connToClient.send([response].pack("I"), 0)
    end

    def addUser()
        jsonData = @connToClient.gets.chomp
        response = @userServer.call('user.addUser', jsonData)
        @connToClient.send([response].pack("I"), 0)
    end

    def rmUser()
        username = @connToClient.gets.chomp
        response = @userServer.call('user.rmUser', username)
        @connToClient.send([response].pack("I"), 0)
    end

    def login()
        jsonData = @connToClient.gets
        hash = JSON.parse(jsonData)
        response = @userServer.call("user.login", jsonData)
        
        @connToClient.puts(response)
        response = JSON.parse(response)
        #puts response.to_s
        if response['returnCode'] == ResponseCodes::SUCCESS
            @isConnected = true
            @user = User.new(hash['username'], nil)
            if (response['superuser'])
                @user.superuser = 1
            end
            self.viewLoop
        else
            @connToClient.close
        end
    end
end