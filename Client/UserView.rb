load "../Model/ResponseCodes.rb"
load "../Model/User.rb"
load "UserController.rb"

class UserView

    attr_accessor:userController
    attr_accessor:userModel

    def initialize (connServer, user)
        @userModel = user
        @userController = UserController.new(connServer, user)
    end

    def viewLoop ()
        userController.remoteDir.push(@userModel.username)
        while userController.isConnected
            print userController.remoteDir.to_path_string + "> "
            cmd = STDIN.gets.chomp().split(" ")
            case cmd[0]
            when "ls"
                @userController.connToServer.puts(cmd[0])
                list = @userController.ls()
                puts list
            when "put"
                @userController.connToServer.puts(cmd[0])
                resp = @userController.put(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    puts "File upload completed."
                else
                    puts "An error occurred."
                end
            when "get"
                @userController.connToServer.puts(cmd[0])
                resp = @userController.get(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                   puts "File download completed." 
                elsif (resp == ResponseCodes::FILE_NOT_FOUND)
                    puts "File not found."
                else
                    puts "An error occurred."
                end
            when "cd"
                if (cmd[1] != "..")
                    @userController.connToServer.puts(cmd[0])
                end
                resp = @userController.cd(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    @userController.remoteDir.push(cmd[1])
                elsif (resp == ResponseCodes::DIRECTORY_NOT_FOUND)
                    puts "Directory #{cmd[1]} not found."
                end
            when "mkdir"
                @userController.connToServer.puts(cmd[0])
                resp = @userController.mkdir(cmd[1])
                if (resp == ResponseCodes::DIRECTORY_EXISTS)
                    puts "The specified directory already exists on server."
                elsif (resp == ResponseCodes::SUCCESS)
                    puts "Directory #{cmd[1]} created with success."
                end
            when "quit"
                @userController.connToServer.puts(cmd[0])
                @userController.quit()
                puts "Connection Closed."
            when "help"
                help()
            else
                puts "Invalid input!"
            end
        end
    end

    def help()
        puts("List of valid commands")
        puts("ls - show the content from the current folder")
        puts("cd %path% - go to %path% folder")
        puts("put %file% - upload a local content to mySFTP server in the current server folder")
        puts("get %file% - download a remote content from mySFTP to the current local folder")
        puts("mkdir %name - create a folder named %name in the current mySFTP folder")
        puts("quit - close the connection and quit the applcation")
    end
end