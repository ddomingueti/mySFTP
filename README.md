# mySFTP
An FTP client and server distributed over Sockets and RPCs

This is a college work, developed by Daniel Bueno Domingueti, during the Distributed Systems course taught by professor Dr. Daniel Guidoni at the Federal University of São João del Rei in the period of 2018/2.

This work consists of the implementation of a client and FTP server using distributed computing, being:
<ul>
  <li> File Server: server where all the data from the users is located (an user have a single folder located on "localpath/data/" folder)
  <li> User Server: is the server that stores user data (mySQL file) and performs the authentication process
  <li> Main Server: is the server responsible for mediating the communication between the client and the other servers
  <li> Client: the client do the interaction with Main Server
</ul>

# Communication Protocol
The comunication between the Main Server and the others servers is done through RPCs, while the communication between the Main Server and the Clients is done through Sockets. There are two kinds of users: the common user (can only manipulate your own files) and the superuser (can manipulate the user database).

To carry out a communication, the following protocol is followed:
<ol>
  <li> The user put a command in your client, and if valid, it is sended to the Main Server
  <li> The Main Server receives the command and prepares the perform the operation
  <li> The Client sends the operation data to the Main Server, and the Main Server makes the correspondenting RPC call
  <li> The Main Server receives the RPC call results and sends it to the client
  <li> The Client receives the results from the operation and shows them
</ol>

# Code Organization

The implementation was done using Ruby and was organized according to the MVC standard. The description of the folders follows:
<ul>
  <li> Client: contains the view from the client, along with the main start script
  <li> Model: contais the models description and the code erros
  <li> Server: contains the implementation from all servers
  <li> Util: Ruby open class extension methods
  <li> Resources: contains the class diagram from the Client and Servers, along with the mySFTP user clean database
</ul>

# Dependencies

This application uses the following gems:
<ul>
  <li> XMLRPC (to perform the communication between Main Server and others servers)
  <li> Json (to pass information throught network)
  <li> mysql2 (to perform the operations involving the user database)
