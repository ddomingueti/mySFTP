require 'socket'
require 'json'
load '../Model/User.rb'
load 'ClientThread.rb'


def main()
    socket = TCPServer.new('127.0.0.1', 3000)

    puts "Server running .... Waiting for connections ... "

    loop do
        socket.listen(1)
        client, client_addr = socket.accept
        clientThread = ClientThread.new(client, client_addr)
        Thread.new { clientThread.login() }
    end
    socket.close()
end

main()