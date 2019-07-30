using JSON2, SGOps

#= Small convenience script to crawl and subsequently write all the xyzt
   forms of the symmetry operations of the 230 three-dimensional space-
   groups. Enables us to just read the symmetry data from the hard-disk
   rather than constantly querying the Bilbao server =#
for i = 1:230
    symops_str = SGOps.crawl_symops_xyzt(i)
    filename = (@__DIR__)*"/../data/symops/3d/sg"*string(i)*".json"
    open(filename; write=true, create=true, truncate=true) do io
        JSON2.write(io, symops_str)
    end 
end

# ----- NOW-REDUNANT FUNCTIONS FOR CRAWLING 3D SPACE GROUPS FROM BILBAO -----
""" 
    crawl_symops_xyzt(sgnum::Integer, dim::Integer=3)

    Obtains the symmetry operations in xyzt format for a given space group
    number `sgnum` by crawling the Bilbao server; see `get_symops` for 
    additional details. Only works for `dim = 3`.
"""
function crawl_symops_xyzt(sgnum::Integer, dim::Integer=3)
    htmlraw = crawl_symops_html(sgnum, dim)

    ops_html = children.(children(last(children(htmlraw.root)))[4:2:end])
    Nops = length(ops_html)
    sgops_str = Vector{String}(undef,Nops)

    for (i,op_html) in enumerate(ops_html)
        sgops_str[i] = stripnum(op_html[1].text) # strip away the space group number
    end
    return sgops_str
end

function crawl_symops_html(sgnum::Integer, dim::Integer=3)
    if dim != 3; error("We do not crawl plane group data; see json files instead; manually crawled.") end
    if sgnum < 1 || sgnum > 230; error(DomainError(sgnum)); end

    if dim == 3
        baseurl = "http://www.cryst.ehu.es/cgi-bin/cryst/programs/nph-getgen?what=text&gnum="
        contents = HTTP.request("GET", baseurl * string(sgnum))
        return parsehtml(String(contents.body))
    else
        error("We did not yet implement 2D plane groups")
    end
end
