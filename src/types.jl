import Base: show

# Crystalline lattice
struct Crystal{N}
    R::NTuple{N,Vector{Float64}}
end
Crystal(R,type) = Crystal{length(R)}(R, type)
Crystal(R) = Crystal{length(R)}(R, "")
basis(C::Crystal) = C.R
dim(C::Crystal{N}) where N = N
function show(io::IO, ::MIME"text/plain", C::Crystal)
    print(io, "$(dim(C))D Crystal:")
    print(io, " ($(crystalsystem(C)))");
    for (i,R) in enumerate(basis(C))
        print(io, "\n   R$(i): "); print(io, R); 
    end
end
norms(C::Crystal) = norm.(basis(C))
_angle(rA,rB) = acos(dot(rA,rB)/(norm(rA)*norm(rB)))
function angles(C::Crystal{N}) where N
    bvecs = basis(C)
    γ = _angle(bvecs[1], bvecs[2])
    if N == 3
        α = _angle(bvecs[2], bvecs[3])
        β = _angle(bvecs[3], bvecs[1])
        return α,β,γ
    end
    return γ
end


# symmetry operations
struct SymOperation
    xyzt::String
    matrix::Matrix{Float64}
end
SymOperation(s::String) = SymOperation(s, xyzt2matrix(s))
matrix(op::SymOperation) = op.matrix
xyzt(op::SymOperation) = op.xyzt
dim(op::SymOperation) = size(matrix(op),1)
function show(io::IO, ::MIME"text/plain", op::SymOperation) 
    print(io, "   (", xyzt(op), ")\n")
    Base.print_matrix(IOContext(io, :compact=>true), op.matrix, "   ")
    print(io, '\n')
end
getindex(op::SymOperation, keys...) = matrix(op)[keys...]   # allows direct indexing into an op::SymOperation like op[1,2] to get matrix(op)[1,2]
lastindex(op::SymOperation, d::Int64) = size(matrix(op), d) # allows using `end` in indices
pg(op::SymOperation) = op[:,1:end-1]        # point group part of an operation
translation(op::SymOperation) = op[:,end]   # translation part of an operation
issymmorph(op::SymOperation) = iszero(translation(op))


# space group
struct SpaceGroup
    num::Int64
    operations::Vector{SymOperation}
    dim::Int64
end
num(sg::SpaceGroup) = sg.num
operations(sg::SpaceGroup) = sg.operations
dim(sg::SpaceGroup) = sg.dim
order(sg::SpaceGroup) = length(operations(sg))
function show(io::IO, ::MIME"text/plain", sg::SpaceGroup)
    Nops = order(sg)
    groupprefix = dim(sg) == 3 ? "Space" : (dim(sg) == 2 ? "Plane" : nothing)
    println(io, groupprefix, " group #", num(sg))
    for (i,op) in enumerate(operations(sg))
        show(io, "text/plain", op)
        if i < Nops; print(io, '\n'); end
    end
end
function show(io::IO, ::MIME"text/plain", sgs::Vector{SpaceGroup})
    Nsgs = length(sgs)
    for (i,sg) in enumerate(sgs); 
        show(io, "text/plain", sg); 
        if i < Nsgs; print(io, '\n'); end
    end
end


# irrep
struct Irrep
    iridx::Int64    # sequential index assigned to ir by Stokes et al
    irlabel::String # CDML label of irrep (including k-point label)
    dim::Int64      # dimensionality of irrep (i.e. size)
    sgnum::Int64    # associated space group number
    sglabel::String # Hermann-Mauguin label of space group
    type::Int64     # real, pseudo-real, or complex (1, 2, or 3)
    order::Int64    # number of operations
    knum::Int64     # number of kvecs in star
    pmknum::Int64   # number of ±kvecs in star
    special::Bool   # whether k-star describes high-symmetry points
    pmkstar::Vector{Tuple{Vector{Float64}, Matrix{Float64}}}  # star of ±k (excludes ± equivalents)
    ops::Vector{SymOperation}         # every symmetry operation in k-star (±?)
    translations::Vector{Any}         # translations assoc with matrix repres of symops in irrep
    matrices::Vector{Matrix{Float64}} # non-translation assoc with matrix repres of symops in irrep
end
#Irrep(matrices::Vector{Matrix{Float64}}) = Irrep(length(matrices), size(matrices[1],1), matrices)
irreps(ir::Irrep) = ir.matrices
characters(ir::Irrep) = tr.(irreps(ir))
order(ir::Irrep) = ir.order
label(ir::Irrep) = ir.irlabel
hermannmauguin(ir::Irrep) = ir.sglabel
operations(ir::Irrep) = ir.ops
isspecial(ir::Irrep) = ir.special
kstar(ir::Irrep) = [ks[1] for ks in ir.pmkstar]
num(ir::Irrep) = ir.sgnum
translations(ir::Irrep) = ir.translations

schar(ir::Irrep) = begin
    m = irreps(ir)
    traces = Vector{Float64}(undef,order(ir))
    if ir.dim/ir.pmknum != div(ir.dim,ir.pmknum)
        error("this doesn't work the way you planned...")
    else
        nblock = div(ir.dim, ir.pmknum)
    end
    for i = 1:order(ir)
        traces[i] = tr(m[i][1:nblock,1:nblock])
    end
    return traces
end