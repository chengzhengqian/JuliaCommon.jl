module JuliaCommon
using DelimitedFiles
export saveData, loadData, linspace
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

# """

# """
# function genePlot(plot_file,data_file;args...)
#     template=read("/home/chengzhengqian/share_workspace/julia_common/plot_template.tex",String)
#     template=replace(template,"FILENAME"=>"$data_file")
#     for (key,val) in args
#         template=replace(template,string(key)=>string(val))
#     end
#     write(plot_file,template)
# end


# "XMIN" "YMIN" "XMAX" "YMAX" "TITLE"
end
