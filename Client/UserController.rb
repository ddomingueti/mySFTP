load '../Util/Array.rb'
load '../Model/ResponseCodes.rb'
load '../Model/User.rb'
require 'json'
#User controller connect the local client to the remote server

class UserController
    attr_accessor:connToServer
    attr_accessor:user
    attr_accessor:isConnected
    attr_accessor:remoteDir
    
    def initialize (connServer, user)
        @connToServer, @user = connServer, user
        @isConnected = false
        @remoteDir = []
    end

    def ls()
        fileList = []
        connToServer.puts(remoteDir.to_path_string)
        jsonData = @connToServer.gets.chomp
        fileList = JSON.parse(jsonData)
        return fileList
    end
    
    def put(filePath)
        file = File.open(Dir.pwd + "/" + filePath, "rb")
        data = ""

        @connToServer.puts(@remoteDir.to_path_string + File.basename(filePath))
        ack = @connToServer.recv(4)
        
        @connToServer.send([file.size].pack("I"), 0)
        ack = @connToServer.recv(4)
        puts "Wait for data upload ... "
        sendSize = 0
        while (sendSize < file.size)  
            amount = if file.size - sendSize > 1024 then 1024 else file.size - sendSize end
            @connToServer.send([amount].pack("I"), 0)
            data = file.read(amount)
            @connToServer.send(data, 0)
            ack = @connToServer.recv(4)
            if (ack.unpack("I")[0] == 1)
                sendSize += amount
            else
                return ResponseCodes::ERROR
                break
            end
        end
        file.close()

        ack = @connToServer.recv(4)
        ack = ack.unpack("I")
        return ack[0]
    end

    def get(fileName)
        @connToServer.puts(@remoteDir.to_path_string + File.basename(fileName))
        ack = @connToServer.recv(4)
        responseAck = ack.unpack("I")
        data = ""
        if (responseAck[0] == ResponseCodes::SUCCESS)
            puts("Download in progress .... ")
            response = @connToServer.recv(4)
            size = response.unpack("I")
            recvSize = 0
            @connToServer.send([1].pack("I"), 0)
            while (recvSize < size[0])
                chunkSize = []
                while (chunkSize.length < 4)
                    chunkSize = @connToServer.recv(4)
                end
                chunkSize = chunkSize.unpack("I")
                parcialData = ""
                parcialData = @connToServer.recv(chunkSize[0])
                data << parcialData
                recvSize += chunkSize[0]
                @connToServer.send([1].pack("I"), 0)
            end
            file = File.open(Dir.pwd + "/" + fileName, "wb")

            file.print(data)
            file.close()
            return ResponseCodes::SUCCESS
        else
            return responseAck[0]
        end
    end
    
    def cd (path)
        newPath = ""
        if (path == "..")
            if (@remoteDir.length > 3)
                @remoteDir.pop(2)
            elsif (@remoteDir.length > 1)
                @remoteDir.pop()
            end
        else
            newPath = @remoteDir.to_path_string + path
            @connToServer.puts(newPath)
            ack = @connToServer.recv(4)
            response = ack.unpack("I")
            return response[0]
        end
    end

    def mkdir(name)
        @connToServer.puts(@remoteDir.to_path_string + name)
        recv = @connToServer.recv(4)
        ack = recv.unpack("I")
        return ack[0]
    end

    def useradd(username)
        print ("Password: ")
        pw = STDIN.gets.chomp
        print ("Superuser (Y/N): ")
        su = STDIN.gets.chomp

        user = User.new(username, pw)
        if (su == "Y" || "y")
            user.superuser = true
        end
        
        @connToServer.puts(user.to_json)

        ack = @connToServer.recv(4)
        ack = ack.unpack("I")
        return ack[0]
    end

    def userrm(username)
        @connToServer.puts(username)
        ack = @connToServer.recv(4)
        ack = ack.unpack("I")
        return ack[0]
    end

    def quit()
        @isConnected = false
        @connToServer.close()
    end
end