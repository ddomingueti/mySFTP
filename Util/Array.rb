class Array
    def to_path_string
        ret = ""
        for it in self
            ret += it + "/"
        end
        return ret
    end
end