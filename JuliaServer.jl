# a language server

module JuliaServer
using JuliaCommon
using Sockets
export start_server, auto_complete
# module_list= [Main,Base,JuliaCommon]
# JuliaServer.module_list= [Main,Base,JuliaCommon]
# there are some problem about the scope, fixed it later

imported_modules=Dict{Symbol,Module}()


# [(v=eval(s);(typeof(v)==Module)&&(JuliaServer.addModule(s,v);println("add $s"))) for s in names(Main;imported=true)];


"""
code snippet to add Modules
"""
function addModule(s,m)
    imported_modules[s]=m
end



function writeLine(sock,str)
    write(sock,str);write(sock,"\n")
end

function auto_complete(str,m,call_back)
    symbols=names(m)
    for s in symbols
        if(startswith(string(s),str))
            call_back(string(s))
        end
    end
end    

# auto_complete("a",Main,println)

function auto_complete(str,call_back)
    for (k,v) in imported_modules
    if(startswith(string(k),str))
        call_back(string(k))
    end
        auto_complete(str,v,call_back)
    end
    call_back(str)
end

# auto_complete("save",println)
        
final_token="!!end"

function run_complete_loop(port)
    server=listen(ip"0.0.0.0",port)
    print("Start server at $(port)\n")
    sock=accept(server)
    print("accept socket form $(getsockname(sock))!\n")
    while true
        content=readline(sock)
        print("[Get request $(content)]\n")
        auto_complete(content,(str)->(writeLine(sock,str)))
        # auto_complete(content,println)
        if(content==final_token)
            print("Stop server\n")
            break
        end
    end
    close(sock)
    close(server)
end

# close(sock)
# close(server
function start_server(port)
    loop=@task run_complete_loop(port);schedule(loop)
    return loop
end

# istaskdone(loop)


end



