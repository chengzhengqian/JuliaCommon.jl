module JuliaCommon
using DelimitedFiles
import Sockets.Sockets
export saveData, loadData, linspace, evalInEmacs, sendCommandToEmacaTerm,czqEmacsSocket

"""
        saveData(data,filename)
"""
saveData(data,filename)= open(filename,"w") do io writedlm(io,data) end

"""
        loadData(filename)
"""
loadData(filename)=readdlm(filename)

"""
generate a linear sequence
"""
linspace(start,stop,length)=range(start,stop=stop,length=length)

# czqEmacsSocket=Sockets.connect("localhost",9001)


function evalInEmacs(str,s)
    write(s,str)
    result_size=parse(Int64,readline(s))
    result=readline(s)
    while(length(result)<result_size)
        result*="\n"*readline(s)
    end
    result
end

# we need to hold it as a dict so we can update it value
czqEmacsSocket=Dict()
evalInEmacs(str)=evalInEmacs(str,czqEmacsSocket["default"])

function sendCommandToEmacaTerm(term,command)
    evalInEmacs("(czq-send-string-term \"$term\"  \"$command\")")
end

end
