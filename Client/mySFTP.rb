require 'socket'
require 'io/console'
require 'json'
load 'UserView.rb'
load '../Model/User.rb'
load '../Model/ResponseCodes.rb'
load "UserView.rb"
load "SuperUserView.rb"

def main(input)
    
    if (input.length != 2)
        puts "Wrong Arguments. Expected: 'IPAdress:Port' UserLogin"
    else
        ip = input[0]
        login = input[1]
        ipAdress = ip.split(":") #ip = ipAdress[0]; port = ipAdress[1]

        puts "Password: "
        pw = STDIN.noecho(&:gets).chomp
        newUser = User.new(login, pw)

        conn = TCPSocket.open(ipAdress[0], ipAdress[1])
        response = newUser.login(conn)
        response = JSON.parse(response)
        if response['returnCode'] == ResponseCodes::SUCCESS
            if (response['superuser'] == 1)
                view = SuperUserView.new(conn, newUser)
                view.userController.isConnected = true
                view.viewLoop()
            else
                view = UserView.new(conn, newUser)
                view.userController.isConnected = true
                view.viewLoop()
            end
        elsif response['returnCode'] == ResponseCodes::USER_NOT_FOUND
            puts "Invalid User and/or Password."
        else
            puts "An error occurred."
        end
        
        conn.close()
    end
end

input = ARGV
main(input)