require 'xmlrpc/server'
require 'base64'
require 'fileutils'
load '../Model/ResponseCodes.rb'

class FileServer

    def initialize()
        @rootDirectory = Dir.new(Dir.pwd + "/data/")
    end

    def ls(directoryPath)
        dir = Dir.new (Dir.pwd + "/data/" + directoryPath)
        list = dir.entries
        dir.close()
        return list
    end

    #true: operation successfull
    #false: operation failed
    def cd(currPath)
        if (Dir.exist?(Dir.pwd + "/data/" + currPath))
            return ResponseCodes::SUCCESS
        else
            return ResponseCodes::DIRECTORY_NOT_FOUND
        end
    end

    def mkdir(currPath)
        if (Dir.exist?(Dir.pwd + "/data/" + currPath))
            return ResponseCodes::DIRECTORY_EXISTS
        end
        Dir.mkdir(Dir.pwd + "/data/" + currPath)
        return ResponseCodes::SUCCESS
    end

    def rmuser(name)
        FileUtils.rm_rf(Dir.pwd + "/data/" + name)
        return ResponseCodes::SUCCESS
    end

    def put(path, data)
        file = File.open(Dir.pwd + "/data/" + path, "wb")
        file.print(Base64.decode64(data))
        file.close
        return ResponseCodes::SUCCESS
    end

    def get(path)
        if (File.exist?(Dir.pwd + "/data/" + path))
            file = File.open(Dir.pwd + "/data/" + path, "rb")
            data = file.read()
            file.close()
            return ResponseCodes::SUCCESS, Base64.encode64(data)
        else
            return ResponseCodes::FILE_NOT_FOUND, 0
        end
    end
end

s = XMLRPC::Server.new(5678)
s.add_handler("file", FileServer.new)
#s.add_handler("file", UserServer.new)

s.set_default_handler do |name, *args|
    raise XMLRPC::FaultException.new(-99, "Method #{name} missing" +
                                     " or wrong number of parameters!")
  end

s.serve
