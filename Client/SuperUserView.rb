load "UserView.rb"

class SuperUserView < UserView
    def initialize(connServer, user)
        super(connServer, user)
    end

    def viewLoop ()
        userController.remoteDir.push(@userModel.username)
        while userController.isConnected
            print userController.remoteDir.to_path_string + "> "
            cmd = STDIN.gets.chomp().split(" ")
            case cmd[0]
            when "ls"
                userController.connToServer.puts(cmd[0])
                list = userController.ls()
                puts list
            when "put"
                userController.connToServer.puts(cmd[0])
                resp = userController.put(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    puts "File upload completed."
                else
                    puts "An error occurred."
                end
            when "get"
                userController.connToServer.puts(cmd[0])
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
                    userController.connToServer.puts(cmd[0])
                end
                resp = userController.cd(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    userController.remoteDir.push(cmd[1])
                elsif (resp == ResponseCodes::DIRECTORY_NOT_FOUND)
                    puts "Directory #{cmd[1]} not found."
                end
            when "mkdir"
                userController.connToServer.puts(cmd[0])
                resp = @userController.mkdir(cmd[1])
                if (resp == ResponseCodes::DIRECTORY_EXISTS)
                    puts "The specified directory already exists on server."
                elsif (resp == ResponseCodes::SUCCESS)
                    puts "Directory #{cmd[1]} created with success."
                end
            when "useradd"
                userController.connToServer.puts(cmd[0])
                resp = userController.useradd(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    puts "User added with success."
                elsif (resp == ResponseCodes::USER_EXISTS)
                    puts "An user already exists on the database with this name."
                end
            when "userrm"
                userController.connToServer.puts(cmd[0])
                resp = userController.userrm(cmd[1])
                if (resp == ResponseCodes::SUCCESS)
                    puts "User removed with success"
                elsif (resp == ResponseCodes::USER_NOT_FOUND)
                    puts "User not found: invalid username"
                end
            when "quit"
                userController.connToServer.puts(cmd[0])
                userController.quit()
                puts "Connection Closed."
            when "help"
                help()
            else
                puts "Invalid input!"
            end
        end
    end

    def help()
        super
        puts "useradd @ - adds a new user named @"
        puts "userrm @ - remove the user named @"
    end

end