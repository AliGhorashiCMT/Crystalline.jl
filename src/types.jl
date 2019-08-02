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
    R = basis(C)
    γ = _angle(R[1], R[2])
    if N == 3
        α = _angle(R[2], R[3])
        β = _angle(R[3], R[1])
        return α,β,γ
    end
    return γ
end


# Symmetry operations
struct SymOperation
    xyzt::String
    matrix::Matrix{Float64}
end
SymOperation(s::String) = SymOperation(s, xyzt2matrix(s))
SymOperation(m::Matrix{Float64}) = SymOperation(matrix2xyzt(m), m)
matrix(op::SymOperation) = op.matrix
xyzt(op::SymOperation) = op.xyzt
dim(op::SymOperation) = size(matrix(op),1)
function show(io::IO, ::MIME"text/plain", op::SymOperation) 
    print(io, "   (", xyzt(op), ")\n")
    Base.print_matrix(IOContext(io, :compact=>true), op.matrix, "   ")
end
getindex(op::SymOperation, keys...) = matrix(op)[keys...]   # allows direct indexing into an op::SymOperation like op[1,2] to get matrix(op)[1,2]
lastindex(op::SymOperation, d::Int64) = size(matrix(op), d) # allows using `end` in indices
pg(m::Matrix{Float64}) = m[:,1:end-1]      # point group part of an operation
pg(op::SymOperation) = matrix(op)[:,1:end-1]        
translation(m::Matrix{Float64}) = m[:,end] # translation part of an operation
translation(op::SymOperation) = matrix(op)[:,end]   
issymmorph(op::SymOperation) = iszero(translation(op))
(==)(op1::SymOperation, op2::SymOperation) = (xyzt(op1) == xyzt(op2)) && (matrix(op1) == matrix(op2))

# Multiplication table
struct MultTable
    operations::Vector{SymOperation}
    indices::Matrix{Int64}
    isgroup::Bool
end
indices(mt::MultTable) = mt.indices
isgroup(mt::MultTable) = mt.isgroup
function show(io::IO, ::MIME"text/plain", mt::MultTable)
    Base.print_matrix(IOContext(io, :compact=>true), mt.indices, "  ")
    print(io, "\nFor operations:\n  ")
    for (i,op) in enumerate(mt.operations)
        print(io, i, " => ", xyzt(op), "\t") # separation could be improved...
        if mod(i,4) == 0; print(io,"\n  "); end
    end
end
getindex(mt::MultTable, keys...) = indices(mt)[keys...]
lastindex(mt::MultTable, d::Int64) = size(indices(mt),d)

# Space group
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
        if i < Nops; print(io, "\n\n"); end
    end
end
function show(io::IO, ::MIME"text/plain", sgs::Vector{SpaceGroup})
    Nsgs = length(sgs)
    for (i,sg) in enumerate(sgs); 
        show(io, "text/plain", sg); 
        if i < Nsgs; print(io, '\n'); end
    end
end


# K-vectors
# 𝐤-vectors are specified as a pair (k₀, kabc), denoting a 𝐤-vector
#       𝐤 = ∑³ᵢ₌₁ (k₀ᵢ + aᵢα+bᵢβ+cᵢγ)*𝐆ᵢ     (w/ recip. basis vecs. 𝐆ᵢ)
# here the matrix kabc is columns of the vectors (𝐚,𝐛,𝐜) while α,β,γ are free
# parameters ranging over all non-special values (i.e. not coinciding with any 
# high-sym 𝐤)
struct KVec
    k₀::Vector{Float64}
    kabc::Matrix{Float64}
end
KVec(k₀::Vector{T}) where T<:Real = KVec(float.(k₀), zeros(Float64, length(k₀), length(k₀)))
parts(kv::KVec) = (kv.k₀, kv.kabc)
isspecial(kv::KVec) = iszero(kv.kabc)
(kv::KVec)(αβγ::Vector{Float64}) = begin
    k₀, kabc = parts(kv)
    return k₀ + kabc*αβγ
end
(kv::KVec)() = kv.k₀
(kv::KVec)(::Nothing) = kv.k₀

function string(kv::KVec)
    k₀, kabc = parts(kv)
    if isspecial(kv)
        return string(k₀)
    else
        buf = IOBuffer()
        write(buf, "[")
        for i in eachindex(k₀)
            write(buf, @sprintf("%g", k₀[i]))
            for j in eachindex(k₀)
                if !iszero(kabc[i,j])
                    write(buf, signaschar(kabc[i,j]))
                    if abs(kabc[i,j]) != oneunit(eltype(kabc))
                        write(buf, @sprintf("%g", abs(kabc[i,j])))
                    end
                    write(buf, j==1 ? 'α' : (j == 2 ? 'β' : 'γ'))
                end
            end
            i == length(k₀) ? write(buf, "]") : write(buf, ", ")
        end
        return String(take!(buf))
    end
end
show(io::IO, ::MIME"text/plain", kv::KVec) = print(io, string(kv))

# Space group irreps
abstract type AbstractIrrep end
struct Irrep{T} <: AbstractIrrep where T
    iridx::Int64    # sequential index assigned to ir by Stokes et al
    cdml::String    # CDML label of irrep (including 𝐤-point label)
    dim::Int64      # dimensionality of irrep (i.e. size)
    sgnum::Int64    # space group number
    sglabel::String # Hermann-Mauguin label of space group
    type::Int64     # real, pseudo-real, or complex (1, 2, or 3)
    order::Int64    # number of operations
    knum::Int64     # number of 𝐤-vecs in star
    pmknum::Int64   # number of ±𝐤-vecs in star
    special::Bool   # whether star{𝐤} describes high-symmetry points
    pmkstar::Vector{KVec}       # star{𝐤} for Complex, star{±𝐤} for Real
    ops::Vector{SymOperation}   # every symmetry operation in space group
    translations::Vector{Vector{Float64}}   # translations assoc with matrix repres of symops in irrep
    matrices::Vector{Matrix{T}} # non-translation assoc with matrix repres of symops in irrep
end
irreps(ir::AbstractIrrep) = ir.matrices
characters(ir::AbstractIrrep) = tr.(irreps(ir))
order(ir::AbstractIrrep) = ir.order
label(ir::AbstractIrrep) = ir.cdml
hermannmauguin(ir::AbstractIrrep) = ir.sglabel
operations(ir::AbstractIrrep) = ir.ops
isspecial(ir::AbstractIrrep) = ir.special
kstar(ir::Irrep) = ir.pmkstar
num(ir::AbstractIrrep) = ir.sgnum
translations(ir::AbstractIrrep) = ir.translations

# Little group Irreps
struct LGIrrep <: AbstractIrrep
    sgnum::Int64 # space group number
    cdml::String # CDML label of irrep (including k-point label)
    k::KVec
    ops::Vector{SymOperation} # every symmetry operation in little group (modulo primitive 𝐆)
    matrices::Vector{Matrix{ComplexF64}}
    translations::Vector{Vector{Float64}}
end
order(ir::LGIrrep) = length(operations(ir))
function irreps(ir::LGIrrep, αβγ::Union{Vector{Float64},Nothing})
    P = ir.matrices
    τ = ir.translations
    if !iszero(τ)
        k = kvec(ir)(αβγ)
        P′ = deepcopy(P)        # needs deepcopy rather than a copy due to nesting; otherwise we overwrite..!
        for (i,τ′) in enumerate(τ)
            if !iszero(τ′) && !iszero(k)
                P′[i] .*= exp(2π*im*k'*τ′)
            end
        end
        return P′
    end
    return P
end
irreps(ir::LGIrrep) = irreps(ir, nothing)
kvec(ir::LGIrrep)   = ir.k
isspecial(ir::LGIrrep) = isspecial(kvec(ir))
issymmorph(ir::LGIrrep) = all(issymmorph.(operations(ir)))

"""
    israyrep(ir::LGIrrep, αβγ=nothing) -> (::Bool, ::Matrix)

    Computes whether a given little group irrep is a ray representation 
    by computing the coefficients αᵢⱼ in DᵢDⱼ=αᵢⱼDₖ; if any αᵢⱼ differ 
    from unity, we consider the little group irrep a ray representation
    (as opposed to the simpler "vector" representations where DᵢDⱼ=Dₖ).
    The function returns a boolean (true => ray representation) and the
    coefficient matrix αᵢⱼ.
"""
function israyrep(ir::LGIrrep, αβγ::Union{Nothing,Vector{Float64}}=nothing) 
    k = kvec(ir)(αβγ)
    ops = operations(ir)
    Nₒₚ = length(ops)
    α = Matrix{ComplexF64}(undef, Nₒₚ, Nₒₚ)
    mt = multtable(ops, verbose=false)
    for (row, oprow) in enumerate(ops)
        for (col, opcol) in enumerate(ops)
            t₀ = translation(oprow) + pg(oprow)*translation(opcol) - translation(ops[mt[row,col]])
            ϕ  = 2π*k'*t₀ # include factor of 2π here due to normalized bases
            α[row,col] = exp(1im*ϕ)
        end
    end
    return (any(x->norm(x-1.0)>1e-12, α), α)
end

function show(io::IO, ::MIME"text/plain", lgir::LGIrrep)
    Nₒₚ = order(lgir)
    print(io, label(lgir))
    indent = " "^length(label(lgir))
    for (i,(op,ir)) in enumerate(zip(operations(lgir), irreps(lgir))); 
        if    i == 1; print(io, " ╮ "); 
        else          print(io, indent, " │ "); end
        print(io, xyzt(op), ":\n")
        Base.print_matrix(IOContext(io, :compact=>true), ir, indent*(i == Nₒₚ ? " ╰" : " │")*"    ")
        if i < Nₒₚ; print(io, '\n'); end
    end
end
function show(io::IO, ::MIME"text/plain", lgirvec::Union{AbstractVector{LGIrrep}, NTuple{N,LGIrrep} where N})
    print(io, "LGIrrep(#", num(lgirvec[1]), ") at ", klabel(label(lgirvec[1])), " = ")
    show(io,"text/plain", kvec(lgirvec[1])); println(io)
    Nᵢᵣ = length(lgirvec)
    for (i,lgir) in enumerate(lgirvec)
        show(io, "text/plain", lgir)
        if i != Nᵢᵣ; println(io); end
    end
end
function findirrep(LGIR, sgnum::Integer, cdml::String)
    kidx = findfirst(x->label(x[1])[1]==cdml[1], LGIR[sgnum])
    irrepidx = findfirst(x->label(x)==cdml, LGIR[sgnum][kidx])
    return LGIR[sgnum][kidx][irrepidx]
end



function printboxchar(io, i, N)
    if i == 1
        print(io, "╭") #┌
    elseif i == N
        print(io, "╰") #┕
    else
        print(io, "│")
    end
end

#println("LGIrrep for space group ", num(lgir), " at ", num)