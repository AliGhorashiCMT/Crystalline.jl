# --- DirectBasis and ReciprocalBasis for crystalline lattices ---
abstract type Basis{D} <: AbstractVector{SVector{D,Float64}} end
for T in (:DirectBasis, :ReciprocalBasis)
    @eval struct $T{D} <: Basis{D}
              vecs::NTuple{D,SVector{D,Float64}}
          end
    @eval $T(Rs::NTuple{D,AbstractVector{<:Real}}) where D = $T{D}(SVector{D,Float64}.(Rs))
    @eval $T(Rs::NTuple{D,NTuple{D,<:Real}}) where D = $T{D}(SVector{D,Float64}.(Rs))
    @eval $T(Rs::AbstractVector{<:Real}...) = $T(Rs)
    @eval $T(Rs::NTuple{D,<:Real}...) where D = $T{D}(SVector{D,Float64}.(Rs))
end

vecs(Vs::Basis) = Vs.vecs
# define the AbstractArray interface for DirectBasis{D}
getindex(Vs::Basis, i::Int) = vecs(Vs)[i] 
firstindex(::Basis) = 1
lastindex(::Basis{D}) where D = D
setindex!(Vs::Basis, vec::Vector{Float64}, i::Int) = (Vs[i] .= vec)
size(::Basis{D}) where D = (D,)
IndexStyle(::Basis) = IndexLinear()
function show(io::IO, ::MIME"text/plain", Vs::DirectBasis) # cannot use for ReciprocalBasis at the moment (see TODO in `crystalsystem`)
    print(io, typeof(Vs))
    print(io, " ($(crystalsystem(Vs))):")
    for (i,V) in enumerate(Vs)
        print(io, "\n   ", V)
    end
end
norms(Rs::Basis) = norm.(Rs)
_angle(rA,rB) = acos(dot(rA,rB)/(norm(rA)*norm(rB)))
function angles(Rs::Basis{D}) where D
    D == 1 && return nothing
    γ = _angle(Rs[1], Rs[2])
    if D == 3
        α = _angle(Rs[2], Rs[3])
        β = _angle(Rs[3], Rs[1])
        return α,β,γ
    end
    return γ
end
"""
    basis2matrix(Vs::Basis{D}) where D

Compute a matrix `[Vs[1] Vs[2] .. Vs[D]]` from `Vs::Basis{D}`, i.e. a matrix whose columns
are the basis vectors in `Vs`. 

Note: Trying to use the iteration interface via `hcat(Vs...)` does not lead to a correctly
      inferred type Matrix::Float64 (and a type-assertion does not improve speed much).
      Instead, we just use the .vec field of `Vs` directly, which achieves good performance.
"""
basis2matrix(Vs::Basis{D}) where D = hcat(vecs(Vs)...)


# --- Symmetry operations ---
struct SymOperation{D} <: AbstractMatrix{Float64}
    matrix::Matrix{Float64}
    # It doesn't seem to be possible to convert `matrix` from ::Matrix{Float64} to
    # ::SMatrix{D,D+1,Float64,D*(D+1)} in a nice way, as it is currently impossible to do
    # computations on type parameters in type definitions, as discussed e.g. in 
    #   https://github.com/JuliaLang/julia/issues/18466 
    #   https://discourse.julialang.org/t/addition-to-parameter-of-parametric-type/20059
    # It doesn't help to split `matrix` into a point `R` and a translation part `τ`, since
    # declaring `R::SMatrix{D,D,Float64,D*D}` also isn't possible; so we'd need to include
    # a useless `L` type, which would be forced to equal `D*D` in the struct constructor.
    # Overall, it doesn't seem worth it at this point: could maybe be done for Julia 2.0.
    # TODO: Splitting `matrix` into a point-group/rotation and a translation part would 
    # probably be worthwhile though, since we only every really deal with them seperately.
end
SymOperation{D}(s::AbstractString) where D = (m=xyzt2matrix(s); SymOperation{D}(m))
# type-unstable convenience constructors; avoid for anything non-REPL related, if possible
SymOperation(m::Matrix{<:Real}) = SymOperation{size(m,1)}(float(m))   
SymOperation(s::AbstractString) = (m=xyzt2matrix(s); SymOperation(m)) 

matrix(op::SymOperation) = op.matrix
xyzt(op::SymOperation) = matrix2xyzt(matrix(op))
dim(::SymOperation{D}) where D = D
# define the AbstractArray interface for SymOperation
getindex(op::SymOperation, keys...) = matrix(op)[keys...]
firstindex(::SymOperation) = 1
lastindex(op::SymOperation{D}) where D = D*(D+1)
lastindex(op::SymOperation{D}, d::Int64) where D = d == 1 ? D : (d == 2 ? D+1 : 1)
IndexStyle(::SymOperation) = IndexLinear()
size(::SymOperation{D}) where D = (D,D+1)
eltype(::SymOperation) = Float64

rotation(m::Matrix{<:Real}) = @view m[:,1:end-1] # rotational (proper or improper) part of an operation
rotation(op::SymOperation)  = rotation(matrix(op))
translation(m::Matrix{<:Real}) = @view m[:,end]  # translation part of an operation
translation(op::SymOperation)  = translation(matrix(op))
(==)(op1::SymOperation, op2::SymOperation) = (dim(op1) == dim(op2) && xyzt(op1) == xyzt(op2)) && (matrix(op1) == matrix(op2))
isapprox(op1::SymOperation, op2::SymOperation; kwargs...)= (dim(op1) == dim(op2) && isapprox(matrix(op1), matrix(op2); kwargs...))
unpack(op::SymOperation) = (rotation(op), translation(op))
function show(io::IO, ::MIME"text/plain", op::SymOperation{D}) where D
    opseitz, opxyzt = seitz(op), xyzt(op)
    print(io, "├─ ", opseitz, " ")
    printstyled(io, repeat('─',36-length(opseitz)-length(opxyzt)), " (", opxyzt, ")"; color=:light_black)
    #Base.print_matrix(IOContext(io, :compact=>true), op.matrix, "   ")
    (D == 1 && return) || println(io) # no need to print a matrix if 1D
    # info that is needed before we start writing by column
    τstrs = fractionify.(translation(op), false)
    Nsepτ = maximum(length, τstrs)
    firstcol_hasnegative = any(signbit, @view op.matrix[:,1])
    for i in 1:D
        print(io, "│  ")
        printstyled(io, i == 1 ? '┌' : (i == D ? '└' : '│'), color=:light_black) # open brace char
        for j in 1:D
            c = op.matrix[i,j]
            # assume and exploit that a valid symop (in the lattice basis only!) never has an 
            # entry that is more than two characters long (namely, -1) in its rotation parts
            sep = repeat(' ', 1+(j ≠ 1 || firstcol_hasnegative)-signbit(c))
            if isinteger(c)
                cᴵ = convert(Int64, op.matrix[i,j])
                printstyled(io, sep, cᴵ, color=:light_black)
            else
                # just use the same sep even if the symop is specified in a nonstandard basis (e.g.
                # cartesian); probably isn't a good general solution, but good enough for now
                printstyled(io, sep, round(c, digits=4), color=:light_black)
            end
        end
        printstyled(io, " ", i == 1 ? "╷" : (i == D ? "╵" : "┆"), " ", repeat(' ', Nsepτ-length(τstrs[i])), τstrs[i], " ", color=:light_black)
        printstyled(io, i == 1 ? '┐' : (i == D ? '┘' : '│'), color=:light_black) # close brace char
        i ≠ D && println(io)
    end
    return
end
# TODO: This is bad style, afaik...
function show(io::IO, ::MIME"text/plain", ops::AbstractVector{<:SymOperation{<:Any}})
    for (i,op) in enumerate(ops)
        show(io, MIME"text/plain"(), op)
        if i < length(ops); println(io, "\n│"); end
    end
end

# --- Multiplication table ---
struct MultTable{D} <: AbstractMatrix{Int64}
    operations::Vector{SymOperation{D}}
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
firstindex(mt::MultTable, d) = 1
lastindex(mt::MultTable, d::Int64) = size(indices(mt),d)

# --- 𝐤-vectors ---
# 𝐤-vectors are specified as a pair (k₀, kabc), denoting a 𝐤-vector
#       𝐤 = ∑³ᵢ₌₁ (k₀ᵢ + aᵢα+bᵢβ+cᵢγ)*𝐆ᵢ     (w/ recip. basis vecs. 𝐆ᵢ)
# here the matrix kabc is columns of the vectors (𝐚,𝐛,𝐜) while α,β,γ are free
# parameters ranging over all non-special values (i.e. not coinciding with any 
# high-sym 𝐤)
struct KVec
    k₀::Vector{Float64}
    kabc::Matrix{Float64}
end
KVec(k₀::AbstractVector{<:Real}) = KVec(float.(k₀), zeros(Float64, length(k₀), length(k₀)))
KVec(k₀s::T...) where T<:Real = KVec([float.(k₀s)...])
parts(kv::KVec) = (kv.k₀, kv.kabc)
dim(kv::KVec) = length(kv.k₀)
isspecial(kv::KVec) = iszero(kv.kabc)
# returns a vector whose entries are true (false) if α,β,γ, respectively, are free parameters (not featured) in `kv`
freeparams(kv::KVec)  = map(j->!iszero(@view kv.kabc[:,j]), Base.OneTo(dim(kv))) 
nfreeparams(kv::KVec) = count(j->!iszero(@view kv.kabc[:,j]), Base.OneTo(dim(kv))) # total number of free parameters in `kv`
function (kv::KVec)(αβγ::AbstractVector{<:Real})
    k₀, kabc = parts(kv)
    return k₀ + kabc*αβγ
end
(kv::KVec)(αβγ::Vararg{<:Real, 2}) = kv([αβγ[1], αβγ[2]])
(kv::KVec)(αβγ::Vararg{<:Real, 3}) = kv([αβγ[1], αβγ[2], αβγ[3]])
(kv::KVec)() = kv.k₀
(kv::KVec)(::Nothing) = kv.k₀

function string(kv::KVec)
    k₀, kabc = parts(kv)
    buf = IOBuffer()
    write(buf, '[')
    if isspecial(kv)
        for i in eachindex(k₀) 
            coord = k₀[i] == -0.0 ? 0.0 : k₀[i] # normalize -0.0 to 0.0
            print(buf, coord)
            # prepare for next coordinate/termination
            i == length(k₀) ? write(buf, ']') : write(buf, ", ")
        end
    else
        for i in eachindex(k₀)
            # fixed parts
            if !iszero(k₀[i]) || iszero(@view kabc[i,:]) # don't print zero, if it adds unto anything nonzero
                coord = k₀[i] == -0.0 ? 0.0 : k₀[i] # normalize -0.0 to 0.0
                print(buf, coord)
            end
            # free-parameter parts
            for j in eachindex(k₀) 
                if !iszero(kabc[i,j])
                    sgn = signaschar(kabc[i,j])
                    if !(iszero(k₀[i]) && sgn=='+' && iszero(kabc[i,1:j-1])) # don't print '+' if nothing precedes it
                        write(buf, sgn)
                    end
                    if abs(kabc[i,j]) != oneunit(eltype(kabc)) # don't print prefactors of 1
                        print(buf, abs(kabc[i,j]))
                    end
                    write(buf, j==1 ? 'α' : (j == 2 ? 'β' : 'γ'))
                end
            end
            # prepare for next coordinate/termination
            i == length(k₀) ? write(buf, ']') : write(buf, ", ")
        end
    end
    return String(take!(buf))
end
show(io::IO, ::MIME"text/plain", kv::KVec) = print(io, string(kv))

""" 
    KVec(str::AbstractString) --> KVec

Construct a `KVec` struct from a string representations of a *k*-vector, supplied 
in either of the formats
        `"(\$x,\$y,\$z)"`, `"[\$x,\$y,\$z]"`, `"\$x,\$y,\$z"`,
where the coordinates `x`,`y`, and `z` are strings that can contain fractions,
decimal numbers, and "free" parameters {`'α'`,`'β'`,`'γ'`} (or, alternatively,
{`'u'`,`'v'`,`'w'`}). Returns the associated `KVec`.

Any "fixed"/constant part of a coordinate _must_ precede any free parts, e.g.,
`x="1+α"` is allowable but `x="α+1"` is not.

Fractions such as `1/2` can be parsed: but use of any other special operator
besides `/` will result in faulty operations (e.g. do not use `*`).
"""
function KVec(str::AbstractString)
    str = filter(!isspace, strip(str, ['(',')','[',']'])) # tidy up string (remove parens & spaces)
    xyz = split(str,',')
    dim = length(xyz)
    k₀ = zeros(Float64, dim); kabc = zeros(Float64, dim, dim)
    for (i, coord) in enumerate(xyz)
        # --- "free" coordinates, kabc[i,:] ---
        for (j, matchgroup) in enumerate((('α','u'),('β','v'),('γ','w')))
            pos₂ = findfirst(∈(matchgroup), coord)
            if !isnothing(pos₂)
                match = searchpriornumerals(coord, pos₂)
                kabc[i,j] = parse(Float64, match)
            end
        end
        
        # --- "fixed" coordinate, k₀[i] ---
        sepidx′ = findfirst(r"\b(\+|\-)", coord) # find any +/- separators between fixed and free parts
        # regex matches '+' or '-', except if they are the first character in 
        # string (or if they are preceded by space; but that cannot occur here)   
        if sepidx′===nothing # no separators
            if last(coord) ∈ ('α','u','β','v','γ','w') # free-part only case
                continue # k₀[i] is zero already
            else                                       # constant-part only case
                k₀[i] = parsefraction(coord)
            end
        else # exploit that we require fixed parts to come before free parts
            k₀[i] = parsefraction(coord[firstindex(coord):prevind(coord, first(sepidx′))])
        end
    end
    return KVec(k₀, kabc)
end

# arithmetic with k-vectors
(-)(kv::KVec) = KVec(.- kv.k₀, .- kv.kabc)
(-)(kv1::KVec, kv2::KVec) = KVec(kv1.k₀ .- kv2.k₀, kv1.kabc .- kv2.kabc)
(+)(kv1::KVec, kv2::KVec) = KVec(kv1.k₀ .+ kv2.k₀, kv1.kabc .+ kv2.kabc)
zero(kv::KVec) = KVec(zero(kv.k₀))

"""
    isapprox(kv1::KVec, kv2::KVec[, cntr::Char]; kwargs...) --> Bool
                                                            
Compute approximate equality of two KVec's `k1` and `k2` modulo any 
primitive G-vectors. To ensure that primitive G-vectors are used, 
the centering type `cntr` (see `centering(cntr, dim)`) must be given
(the dimensionality is inferred from `kv1` and `kv2`).
Optionally, keyword arguments (e.g., `atol` and `rtol`) can be 
provided, to include in calls to `Base.isapprox`.

If `cntr` is not provided, the comparison will not account for equivalence
by primitive G-vectors.
"""
function isapprox(kv1::KVec, kv2::KVec, cntr::Char; kwargs...)
    k₀1, kabc1 = parts(kv1); k₀2, kabc2 = parts(kv2)  # ... unpacking

    dim1, dim2 = length(k₀1), length(k₀2)
    if dim1 ≠ dim2
        throw(ArgumentError("dim(kv1)=$(dim1) and dim(kv2)=$(dim2) must be equal"))
    end

    # check if k₀ ≈ k₀′ differ by a _primitive_ 𝐆 vector
    diff = primitivebasismatrix(cntr, dim1)' * (k₀1 .- k₀2)
    kbool = all(el -> isapprox(el, round(el); kwargs...), diff) 
    # check if kabc1 ≈ kabc2; no need to check for difference by a 
    # 𝐆 vector, since kabc is in interior of BZ
    abcbool = isapprox(kabc1, kabc2;  kwargs...)

    return kbool && abcbool
end
# ... without considerations of G-vectors
function isapprox(kv1::KVec, kv2::KVec; kwargs...) 
    k₀1, kabc1 = parts(kv1); k₀2, kabc2 = parts(kv2)  # ... unpacking
       
    return isapprox(k₀1, k₀2; kwargs...) && isapprox(kabc1, kabc2; kwargs...)
end

function (==)(kv1::KVec, kv2::KVec)   
    k₀1, kabc1 = parts(kv1); k₀2, kabc2 = parts(kv2)  # ... unpacking
       
    return k₀1 == k₀2 && kabc1 == kabc2
end

# mostly a utility function for visualizing the `KVec`s in a `LittleGroup`
function plot(kv::KVec, 
              ax=plt.figure().gca(projection= dim(kv)==3 ? (using3D(); "3d") : "rectilinear"))   
    D = dim(kv)
    freeαβγ = freeparams(kv)
    nαβγ = count(freeαβγ)
    nαβγ == 3 && return ax # general point/volume (nothing to plot)

    _scatter = D == 3 ? ax.scatter3D : ax.scatter
    _plot    = D == 3 ? ax.plot3D : ax.plot
 
    if nαβγ == 0 # point
        k = kv()
        _scatter(k...)
    elseif nαβγ == 1 # line
        k⁰, k¹ = kv(zeros(D)), kv(freeαβγ.*0.5)
        ks = [[k⁰[i], k¹[i]] for i in 1:D]
        _plot(ks...)
    elseif nαβγ == 2 && D > 2 # plane
        k⁰⁰, k¹¹ = kv(zeros(D)), kv(freeαβγ.*0.5)
        αβγ, j = (zeros(3), zeros(3)), 1
        for i = 1:3
            if freeαβγ[i]
                αβγ[j][i] = 0.5
                j += 1
            end
        end
        k⁰¹, k¹⁰ = kv(αβγ[1]), kv(αβγ[2])
        # calling Poly3DCollection is not so straightforward: follow the advice
        # at https://discourse.julialang.org/t/3d-polygons-in-plots-jl/9761/3
        verts = ([tuple(k⁰⁰...); tuple(k¹⁰...); tuple(k¹¹...); tuple(k⁰¹...)],)
        plane = PyPlot.PyObject(art3D).Poly3DCollection(verts, alpha = 0.15)
        PyPlot.PyCall.pycall(plane.set_facecolor, PyPlot.PyCall.PyAny, [52, 152, 219]./255)
        PyPlot.PyCall.pycall(ax.add_collection3d, PyPlot.PyCall.PyAny, plane)
    end
    return ax
end


# --- Abstract spatial group ---
abstract type AbstractGroup{D} <: AbstractVector{SymOperation{D}} end
num(g::AbstractGroup) = g.num
operations(g::AbstractGroup) = g.operations
dim(g::AbstractGroup{D}) where D = D
# define the AbstractArray interface for AbstractGroup
getindex(g::AbstractGroup, keys...) = operations(g)[keys...]    # allows direct indexing into an op::SymOperation like op[1,2] to get matrix(op)[1,2]
firstindex(::AbstractGroup) = 1
lastindex(g::AbstractGroup, d::Int64) = size(operations(g), d)  # allows using `end` in indices
setindex!(g::AbstractGroup, op::SymOperation, i::Int) = (operations(g)[i] .= op)
size(g::AbstractGroup) = (length(operations(g)),)
IndexStyle(::AbstractGroup) = IndexLinear()
eltype(::AbstractGroup{D}) where D = SymOperation{D}
order(g::AbstractGroup) = length(g)

function show(io::IO, ::MIME"text/plain", g::T) where T<:AbstractGroup
    if isa(g, SpaceGroup)
        groupprefix = dim(g) == 3 ? "Space group" : (dim(g) == 2 ? "Plane group" : "Line group")
    elseif isa(g, PointGroup)
        groupprefix = "Point group"
    else
        groupprefix = string(T)
    end
    println(io, groupprefix, " #", num(g), " (", label(g), ") with ", order(g), " operations:")
    show(io, "text/plain", operations(g))
end
function show(io::IO, ::MIME"text/plain", gs::AbstractVector{<:AbstractGroup})
    Ngs = length(gs)
    for (i,g) in enumerate(gs); 
        show(io, "text/plain", g); 
        if i < Ngs; print(io, '\n'); end
    end
end

# --- Space group ---
struct SpaceGroup{D} <: AbstractGroup{D}
    num::Int64
    operations::Vector{SymOperation{D}}
end
label(sg::SpaceGroup) = iuc(sg)

# --- Point group ---
struct PointGroup{D} <: AbstractGroup{D}
    num::Int64
    label::String
    operations::Vector{SymOperation{D}}
end
label(pg::PointGroup) = pg.label
iuc(pg::PointGroup) = label(pg)

# --- Little group ---
struct LittleGroup{D} <: AbstractGroup{D}
    num::Int64
    kv::KVec
    klab::String
    operations::Vector{SymOperation{D}}
end
LittleGroup(num::Int64, kv::KVec, klab::String, ops::AbstractVector{SymOperation{D}}) where D = LittleGroup{D}(num, kv, klab, ops)
LittleGroup(num::Int64, kv::KVec, ops::AbstractVector{SymOperation{D}}) where D = LittleGroup{D}(num, kv, "", ops)
kvec(lg::LittleGroup) = lg.kv
klabel(lg::LittleGroup) = lg.klab
label(lg::LittleGroup)  = iuc(num(lg), dim(lg))*" at "*klabel(lg)*" = "*string(kvec(lg))

# plotting of `KVec`s in a `LittleGroup`
function plot(kvs::AbstractVector{KVec})
    D = dim(first(kvs))
    ax = plt.figure().gca(projection= D==3 ? (using3D(); "3d") : "rectilinear")
    for kv in kvs
        plot(kv, ax)
    end
    return ax
end
plot(lgs::AbstractVector{<:LittleGroup}) = plot(kvec.(lgs))

# --- Abstract group irreps ---
""" 
    AbstractIrrep{D} (abstract type)

Abstract supertype for irreps of dimensionality `D`: must have fields `cdml`, `matrices`,
and `type` (and possibly `translations`). Must implement a function `irreps` that returns
the associated irrep matrices.
"""
abstract type AbstractIrrep{D} end
label(ir::AbstractIrrep) = ir.cdml
matrices(ir::AbstractIrrep) = ir.matrices    
type(ir::AbstractIrrep) = ir.type
translations(ir::T) where T<:AbstractIrrep = hasfield(T, :translations) ? ir.translations : nothing
characters(ir::AbstractIrrep, αβγ::Union{AbstractVector{<:Real},Nothing}=nothing) = tr.(irreps(ir, αβγ))
irdim(ir::AbstractIrrep)  = size(first(matrices(ir)),1)
klabel(ir::AbstractIrrep) = klabel(label(ir))
order(ir::AbstractIrrep)  = order(group(ir))
operations(ir::AbstractIrrep) = operations(group(ir))
num(ir::AbstractIrrep) = num(group(ir))
dim(ir::AbstractIrrep{D}) where D = D
function klabel(cdml::String)
    idx = findfirst(c->isdigit(c) || issubdigit(c), cdml) # look for regular digit or subscript digit
    previdx = idx !== nothing ? prevind(cdml, idx) : lastindex(cdml)
    return cdml[firstindex(cdml):previdx]
end

# --- Point group irreps ---
struct PGIrrep{D} <: AbstractIrrep{D}
    cdml::String
    pg::PointGroup{D}
    matrices::Vector{Matrix{ComplexF64}}
    type::Int64
end
irreps(pgir::PGIrrep, αβγ::Nothing=nothing) = pgir.matrices
group(pgir::PGIrrep) = pgir.pg

# printing
function prettyprint_irrep_matrix(io::IO, pgir::PGIrrep, i::Integer, prefix::AbstractString)
    P = pgir.matrices[i]
    prettyprint_scalar_or_matrix(io, P, prefix, false)
end

# --- Little group irreps ---
struct LGIrrep{D} <: AbstractIrrep{D}
    cdml::String # CDML label of irrep (including k-point label)
    lg::LittleGroup{D} # contains sgnum, kvec, klab, and operations that define the little group (and dimension as type parameter)
    matrices::Vector{Matrix{ComplexF64}}
    translations::Vector{Vector{Float64}}
    type::Int64 # real, pseudo-real, or complex (⇒ 1, 2, or 3)
    iscorep::Bool # Whether this irrep really represents a corep (only relevant for `type`s 2 and 3; leads to special handling for `irreps(..)` and printing)
end
function LGIrrep{D}(cdml::String, lg::LittleGroup{D}, 
                    matrices::Vector{Matrix{ComplexF64}}, 
                    translations::Vector{Vector{Float64}},
                    type::Int64) where D
    return LGIrrep{D}(cdml, lg, matrices, translations, type, false)
end
function LGIrrep{D}(cdml::String, lg::LittleGroup{D}, 
                    matrices::Vector{Matrix{ComplexF64}}, 
                    translations_sentinel::Nothing, # sentinel value for all-zero translations
                    type::Int64) where D
    translations = [zeros(Float64,D) for _=Base.OneTo(order(lg))]
    return LGIrrep{D}(cdml, lg, matrices, translations, type)
end
group(lgir::LGIrrep) = lgir.lg
iscorep(lgir::LGIrrep) = lgir.iscorep
kvec(lgir::LGIrrep)  = kvec(group(lgir))
isspecial(lgir::LGIrrep)  = isspecial(kvec(lgir))
issymmorph(lgir::LGIrrep) = issymmorph(group(lgir))
kstar(lgir::LGIrrep) = kstar(spacegroup(num(lgir), dim(lgir)), 
                             kvec(lgir), centering(num(lgir), dim(lgir)))
function irreps(lgir::LGIrrep, αβγ::Union{Vector{<:Real},Nothing}=nothing)
    P = lgir.matrices
    τ = lgir.translations
    if !iszero(τ)
        k = kvec(lgir)(αβγ)
        P = deepcopy(P) # needs deepcopy rather than a copy due to nesting; otherwise we overwrite..!
        for (i,τ′) in enumerate(τ)
            if !iszero(τ′) && !iszero(k)
                P[i] .*= cis(2π*dot(k,τ′)) # This follows the convention in Eq. (11.37) of Inui as well as the 
                # note cis(x) = exp(ix)     # Bilbao server; but disagrees (as far as I can tell) with some
                                            # other references (e.g. Herring 1937a, Bilbao's _publications_?!, 
                                            # and Kovalev's book).
                                            # In those other references they have Dᵏ({I|𝐭}) = exp(-i𝐤⋅𝐭), but 
                                            # Inui has Dᵏ({I|𝐭}) = exp(i𝐤⋅𝐭) [cf. (11.36)]. The former choice 
                                            # actually appears more natural, since we usually have symmetry 
                                            # operations acting inversely on functions of spatial coordinates. 
                                            # If we swap the sign here, we probably have to swap t₀ in the check
                                            # for ray-representations in multtable(::MultTable, ::LGIrrep), to 
                                            # account for this difference. It is not enough just to swap the sign
                                            # - I checked (⇒ 172 failures in test/multtable.jl) - you would have 
                                            # to account for the fact that it would be -β⁻¹τ that appears in the 
                                            # inverse operation, not just τ. Same applies here, if you want to 
                                            # adopt the other convention, it should probably not just be a swap 
                                            # to -τ, but to -β⁻¹τ. Probably best to stick with Inui's definition.
                                            # Note that the exp(2πi𝐤⋅τ) is also the convention adopted by Stokes
                                            # et al in Eq. (1) of Acta Cryst. A69, 388 (2013), i.e. in ISOTROPY 
                                            # (also expliciated at https://stokes.byu.edu/iso/irtableshelp.php),
                                            # so, overall, this is probably the sanest choice for this dataset.
            end
        end
    end

    if iscorep(lgir)
        t = type(lgir) 
        if t == 2 # Pseudo-real (doubles)
            return _blockdiag2x2.(P)
        elseif t == 3 # Complex (conj-doubles)
            return _blockdiag2x2_conj.(P)
        else
            throw(DomainError(type, "Unexpected combination of iscorep=true and type≠{2,3}"))
        end
    else
        return P
    end
    return P
end

function _blockdiag2x2(A::Matrix{T}) where T
    n = LinearAlgebra.checksquare(A)
    B = zeros(T, 2*n, 2*n)
    @inbounds for I in 0:1
        I′ = I*n
        for i in Base.OneTo(n)
            i′ = I′+i
            for j in Base.OneTo(n)
                B[i′,I′+j] = A[i,j]
            end
        end
    end
    return B
end
function _blockdiag2x2_conj(A::Matrix{T}) where T
    n = LinearAlgebra.checksquare(A)
    B = zeros(T, 2*n, 2*n)
    @inbounds for i in Base.OneTo(n) # upper left block
        for j in Base.OneTo(n)
            B[i,j] = A[i,j]
        end
    end
    @inbounds for i in Base.OneTo(n) # lower right block
        i′ = n+i
        for j in Base.OneTo(n)
            B[i′,n+j] = conj(A[i,j])
        end
    end
    return B
end

"""
    israyrep(lgir::LGIrrep, αβγ=nothing) -> (::Bool, ::Matrix)

Computes whether a given little group irrep `ir` is a ray representation 
by computing the coefficients αᵢⱼ in DᵢDⱼ=αᵢⱼDₖ; if any αᵢⱼ differ 
from unity, we consider the little group irrep a ray representation
(as opposed to the simpler "vector" representations where DᵢDⱼ=Dₖ).
The function returns a boolean (true => ray representation) and the
coefficient matrix αᵢⱼ.
"""
function israyrep(lgir::LGIrrep, αβγ::Union{Nothing,Vector{Float64}}=nothing) 
    k = kvec(lgir)(αβγ)
    ops = operations(lgir)
    Nₒₚ = length(ops)
    α = Matrix{ComplexF64}(undef, Nₒₚ, Nₒₚ)
    # TODO: Verify that this is OK; not sure if we can just use the primitive basis 
    #       here, given the tricks we then perform subsequently?
    mt = multtable(primitivize.(ops, centering(num(lgir))), verbose=false) 
    for (row, oprow) in enumerate(ops)
        for (col, opcol) in enumerate(ops)
            t₀ = translation(oprow) + rotation(oprow)*translation(opcol) - translation(ops[mt[row,col]])
            ϕ  = 2π*dot(k,t₀) # include factor of 2π here due to normalized bases
            α[row,col] = cis(ϕ)
        end
    end
    return any(x->norm(x-1.0)>DEFAULT_ATOL, α), α
end

# methods to print PGIrreps and LGIrreps ...
function prettyprint_scalar_or_matrix(io::IO, printP::AbstractMatrix, prefix::AbstractString,
                                      ϕabc_contrib::Bool=false)
    if size(printP) == (1,1) # scalar case
        v = printP[1]
        if isapprox(v, real(v), atol=DEFAULT_ATOL)          # real scalar
            if ϕabc_contrib && abs(real(v)) ≈ 1.0
                signbit(real(v)) && print(io, '-')
            else
                print(io, real(v))
            end
        elseif isapprox(v, imag(v)*im, atol=DEFAULT_ATOL)   # imaginary scalar
            if ϕabc_contrib && abs(imag(v)) ≈ 1.0
                signbit(imag(v)) && print(io, '-')
            else
                print(io, imag(v))
            end
            print(io, "i")
        else                                                # complex scalar (print as polar)
            vρ, vθ = abs(v), angle(v)
            vθ /= π
            print(io, vρ  ≈ 1.0 ? "" : vρ, "exp(") 
            if abs(vθ) ≈ 1.0
                signbit(vθ) && print(io, '-')
            else
                print(io, vθ)
            end
            print(io, "iπ)")
            #print(io, ϕabc_contrib ? "(" : "", v, ϕabc_contrib ? ")" : "")
        end

    else # matrix case
        formatter = x->(xr = real(x); xi = imag(x);
                        ComplexF64(abs(xr) > DEFAULT_ATOL ? xr : 0.0,
                                   abs(xi) > DEFAULT_ATOL ? xi : 0.0)) # round small complex components to zero

        compact_print_matrix(io, printP, prefix, formatter) # not very optimal; e.g. makes a whole copy and doesn't handle displaysize
    end
end
function prettyprint_irrep_matrix(io::IO, lgir::LGIrrep, i::Integer, prefix::AbstractString)
    # unpack
    k₀, kabc = parts(lgir.lg.kv)
    P = lgir.matrices[i]
    τ = lgir.translations[i]

    # phase contributions
    ϕ₀ = dot(k₀, τ)                                   # constant phase
    ϕabc = [dot(kabcⱼ, τ) for kabcⱼ in eachcol(kabc)] # variable phase
    ϕabc_contrib = norm(ϕabc) > sqrt(dim(lgir))*DEFAULT_ATOL

    # print the constant part of the irrep that is independent of α,β,γ
    printP = abs(ϕ₀) < DEFAULT_ATOL ? P : cis(2π*ϕ₀)*P # avoids copy if ϕ₀≈0; copies otherwise
    prettyprint_scalar_or_matrix(io, printP, prefix, ϕabc_contrib)

    # print the variable phase part that depends on the free parameters α,β,γ 
    if ϕabc_contrib
        nnzabc = count(c->abs(c)>DEFAULT_ATOL, ϕabc)
        print(io, "exp")
        if nnzabc == 1
            print(io, "(")
            i = findfirst(c->abs(c)>DEFAULT_ATOL, ϕabc)
            c = ϕabc[i]
            signbit(c) && print(io, "-")
            abs(c) ≈ 0.5 || print(io, abs(2c)) # do not print if multiplicative factor is 1

            print(io, "iπ", 'ΰ'+i, ")") # prints 'α', 'β', and 'γ' for i = 1, 2, and 3, respectively ('ΰ'='α'-1)

        else
            print(io, "[iπ(")
            first_nzidx = true
            for (i,c) in enumerate(ϕabc)
                if abs(c) > DEFAULT_ATOL
                    if first_nzidx 
                        signbit(c) && print(io, '-')
                        first_nzidx = false
                    else
                        print(io, signaschar(c))
                    end
                    abs(c) ≈ 0.5 || print(io, abs(2c)) # do not print if multiplicative factor is 1
                    print(io, 'ΰ'+i) # prints 'α', 'β', and 'γ' for i = 1, 2, and 3, respectively ('ΰ'='α'-1)
                end
            end
            print(io, ")]")
        end
    end
    
    # Least-effort way to indicate nontrivial (pseudo-real/complex) co-representations
    # TODO: Improve printing of pseudo-real and complex LGIrrep co-representations?
    if iscorep(lgir) 
        if type(lgir) == 2     # pseudo-real
            print(io, " + block-repetition")
        elseif type(lgir) == 3 # complex
            print(io, " + conjugate-block-repetition")
        else
            throw(DomainError(type, "Unexpected combination of iscorep=true and type≠{2,3}"))
        end
    end
end
function prettyprint_irrep_matrices(io::IO, plgir::Union{<:LGIrrep, <:PGIrrep}, 
                                  nindent::Integer, nboxdelims::Integer=45)  
    indent = repeat(" ", nindent)
    boxdelims = repeat("─", nboxdelims)
    linelen = nboxdelims + 4 + nindent
    Nₒₚ = order(plgir)
    for (i,op) in enumerate(operations(plgir))
        print(io, indent, " ├─ ")
        opseitz, opxyzt  = seitz(op), xyzt(op)
        printstyled(io, opseitz, ": ", 
                        repeat("─", linelen-11-nindent-length(opseitz)-length(opxyzt)),
                        " (", opxyzt, ")\n"; color=:light_black)
        #Base.print_matrix(IOContext(io, :compact=>true), ir, indent*(i == Nₒₚ ? " ╰" : " │")*"    ")
        print(io, indent, " │     ")
        prettyprint_irrep_matrix(io, plgir, i, indent*" │     ")
        if i < Nₒₚ; println(io, '\n', indent, " │     "); end
    end
    print(io, "\n", indent, " └", boxdelims)
end
function prettyprint_header(io::IO, plgirlab::AbstractString, nboxdelims::Integer=45)
    println(io, plgirlab, " ─┬", repeat("─", nboxdelims))
end
function show(io::IO, ::MIME"text/plain", plgir::Union{<:LGIrrep, <:PGIrrep})
    lgirlab = formatirreplabel(label(plgir))
    lablen = length(lgirlab)
    nindent = lablen+1
    prettyprint_header(io, lgirlab)
    prettyprint_irrep_matrices(io, plgir, nindent)
end
function show(io::IO, ::MIME"text/plain", plgirs::AbstractVector{T}) where T<:Union{<:LGIrrep, <:PGIrrep}
    println(io, "$T: #", num(first(plgirs)), "/", label(group(first(plgirs))))
    Nᵢᵣ = length(plgirs)
    for (i,plgir) in enumerate(plgirs)
        show(io, "text/plain", plgir)
        if i != Nᵢᵣ; println(io); end
    end
end
function show(io::IO, ::MIME"text/plain", lgirsvec::AbstractVector{<:AbstractVector{<:LGIrrep}})
    for lgirs in lgirsvec
        show(io, "text/plain", lgirs)
        println(io)
    end
end

function find_lgirreps(lgirsvec::AbstractVector{<:AbstractVector{<:LGIrrep}}, klab::String, verbose::Bool=false)
    kidx = findfirst(x->klabel(first(x))==klab, lgirsvec)
    if kidx === nothing
        if verbose
            println("Didn't find any matching k-label in lgirsvec: "*
                    "the label may be specified incorrectly, or the irrep is missing "*
                    "(e.g. the irrep could be a axes-dependent irrep)")
            @info klab klabel.(first.(lgirsvec))
        end
        return nothing 
    else
        return lgirsvec[kidx] # return an "lgirs" (vector of `LGIrrep`s)
    end
end
find_lgirreps(sgnum::Integer, klab::String, Dᵛ::Val{D}) where D = find_lgirreps(get_lgirreps(sgnum, Dᵛ), klab)
find_lgirreps(sgnum::Integer, klab::String, D::Integer=3) = find_lgirreps(sgnum, klab, Val(D))



# --- Character table ---
struct CharacterTable{D}
    ops::Vector{SymOperation{D}}
    irlabs::Vector{String}
    chartable::Matrix{ComplexF64} # Stored as irreps-along-columns & operations-along-rows
    # TODO: for LGIrreps, it might be nice to keep this more versatile and include the 
    #       translations and kvec as well; then we could print a result that doesn't  
    #       specialize on a given αβγ choice (see also CharacterTable(::LGirrep))
    tag::String
end
CharacterTable{D}(ops::AbstractVector{SymOperation{D}}, 
                  irlabs::Vector{String}, 
                  chartable::Matrix{ComplexF64}) where D = CharacterTable{D}(ops, irlabs, chartable, "")
operations(ct::CharacterTable) = ct.ops
labels(ct::CharacterTable) = ct.irlabs
characters(ct::CharacterTable) = ct.chartable
tag(ct::CharacterTable) = ct.tag

function show(io::IO, ::MIME"text/plain", ct::CharacterTable)
    chars = characters(ct)
    chars_formatted = Array{Union{Float64, Int64, ComplexF64, Complex{Int64}}}(undef, size(chars))
    for (idx, c) in enumerate(chars)
        chars_formatted[idx] = if isreal(c)
            isinteger(real(c)) ? convert(Int64, real(c)) : real(c)
        else
            ((isinteger(real(c)) && isinteger(imag(c))) 
                      ? convert(Int64, real(c)) + convert(Int64, imag(c))
                      : c)
        end
    end
    println(io, typeof(ct), ": ", tag(ct)) # type name and space group/k-point tags
    pretty_table(io,
                 [seitz.(operations(ct)) chars_formatted], # 1st column: seitz operations; then formatted character table
                 ["" formatirreplabel.(labels(ct))...];    # 1st row (header): irrep labels
                 tf = unicode,
                 highlighters = Highlighter((data,i,j) -> i==1 || j==1; bold=true),
                 vlines = [1,], hlines = [:begin, 1, :end]
                )
end

"""
    CharacterTable(irs::AbstractVector{<:AbstractIrrep}, αβγ=nothing)

Returns a `CharacterTable` associated with vector of `AbstractIrrep`s `irs`. 

Optionally, an `αβγ::AbstractVector{<:Real}` variable can be passed to evaluate the irrep
(and associated characters) with concrete free parameters (e.g., for `LGIrrep`s, a concrete
k-vector sampled from a "line-irrep"). Defaults to `nothing`, indicating it being either 
irrelevant (e.g., for `PGIrrep`s) or all free parameters implicitly set to zero.
"""
function CharacterTable(irs::AbstractVector{<:AbstractIrrep{D}},
                        αβγ::Union{AbstractVector{<:Real}, Nothing}=nothing) where D
    table = Array{ComplexF64}(undef, order(first(irs)), length(irs))
    for (i,col) in enumerate(eachcol(table))
        col .= characters(irs[i], αβγ)
    end
    g = group(first(irs))
    tag = "#"*string(num(g))*"/"*label(g)
    return CharacterTable{D}(operations(first(irs)), label.(irs), table, tag)
end

# --- Band representations ---
struct BandRep <: AbstractVector{Int64}
    wyckpos::String  # Wyckoff position that induces the BR
    sitesym::String  # Site-symmetry point group of Wyckoff pos (IUC notation)
    label::String    # Symbol ρ↑G, with ρ denoting the irrep of the site-symmetry group
    dim::Integer     # Dimension (i.e. # of bands) in band rep
    decomposable::Bool  # Whether a given bandrep can be decomposed further
    spinful::Bool       # Whether a given bandrep involves spinful irreps ("\bar"'ed irreps)
    irrepvec::Vector{Int64}   # Vector the references irreplabs of a parent BandRepSet; 
                              # nonzero entries correspond to an element in the band representation
    irreptags::Vector{String} # vestigial, but quite handy for display'ing; this otherwise 
                              # requires recursive data sharing between BandRep and BandRepSet
end
wyck(BR::BandRep)    = BR.wyckpos
sitesym(BR::BandRep) = BR.sitesym
label(BR::BandRep)   = BR.label
humanreadable(BR::BandRep) = BR.irreptags
vec(BR::BandRep)     = BR.irrepvec
function show(io::IO, ::MIME"text/plain", BR::BandRep)
    print(label(BR), " (", dim(BR), "): [")
    join(io, map(Base.Fix2(replace, '⊕'=>'+'), humanreadable(BR)), ", ") # ⊕ doesn't render well in my terminal; swap for ordinary plus
    print(io, "]")
end
"""
    dim(BR::BandRep) --> Int64

Get the number of bands included in a single BandRep `BR`; i.e. the "band filling"
ν discussed in Po's papers.
"""
dim(BR::BandRep)     = BR.dim

# define the AbstractArray interface for BandRep
size(BR::BandRep)    = (length(vec(BR)),) # number of irreps samplable by BandRep
getindex(BR::BandRep, keys...) = vec(BR)[keys...]
firstindex(::BandRep) = 1
lastindex(BR::BandRep) = length(vec(BR))
IndexStyle(::BandRep) = IndexLinear()
eltype(::BandRep) = Int64

struct BandRepSet <: AbstractVector{BandRep}
    sgnum::Integer          # space group number, sequential
    bandreps::Vector{BandRep}
    kvs::Vector{KVec}       # Vector of 𝐤-points
    klabs::Vector{String}   # Vector of associated 𝐤-labels (in CDML notation)
    irreplabs::Vector{String} # Vector of (sorted) CDML irrep labels at _all_ 𝐤-points
    allpaths::Bool          # Whether all paths (true) or only maximal 𝐤-points (false) are included
    spinful::Bool           # Whether the band rep set includes (true) or excludes (false) spinful irreps
    timeinvar::Bool         # Whether the band rep set assumes time-reversal symmetry (true) or not (false) 
end
num(BRS::BandRepSet)         = BRS.sgnum
klabels(BRS::BandRepSet)     = BRS.klabs
kvecs(BRS::BandRepSet)       = BRS.kvs
hasnonmax(BRS::BandRepSet)   = BRS.allpaths
irreplabels(BRS::BandRepSet) = BRS.irreplabs
isspinful(BRS::BandRepSet)   = BRS.spinful
istimeinvar(BRS::BandRepSet) = BRS.timeinvar
reps(BRS::BandRepSet)        = BRS.bandreps

# define the AbstractArray interface for BandRepSet
size(BRS::BandRepSet) = (length(reps(BRS)),) # number of distinct band representations
getindex(BRS::BandRepSet, keys...) = reps(BRS)[keys...]
firstindex(::BandRepSet) = 1
lastindex(BRS::BandRepSet) = length(reps(BRS))
IndexStyle(::BandRepSet) = IndexLinear()
eltype(::BandRepSet) = BandRep

# matrix representation of a BandRepSet, with band reps along rows and irreps along columns,
# if `includedim` is `true` (`false` by default) the band filling (i.e. `dim.(BRS)`) will be
# included as the last column
function matrix(BRS::BandRepSet, includedim::Bool=false)
    # TODO: It would be better to have the matrix return columns of EBRs instead of rows
    Nirs = length(BRS[1])
    M = Matrix{Int64}(undef, length(BRS), Nirs+includedim)
    @inbounds for (i, BR) in enumerate(BRS)
        for (j, v) in enumerate(vec(BR)) # bit over-explicit, but faster this way than with 
            M[i,j] = v                   # broadcasting/iterator interface (why!?)
        end
        if includedim
            M[i,Nirs+1] = dim(BR)
        end
    end
    
    return M
end 

function show(io::IO, ::MIME"text/plain", BRS::BandRepSet)
    Nirreps = length(irreplabels(BRS))
    println(io, "BandRepSet (#$(num(BRS))):")
    println(io, "k-vecs ($(hasnonmax(BRS) ? "incl. non-maximal" : "maximal only")):")
    for (lab,kv) in zip(klabels(BRS), kvecs(BRS))
        print(io,"   ", lab, ": "); show(io, "text/plain", kv); println(io)
    end

    # prep-work to figure out how many irreps we can write to the io
    ν_maxdigs = maximum(ndigits∘dim, reps(BRS))
    cols_brlab = maximum(x->length(label(x)), reps(BRS))+1
    cols_irstart = cols_brlab+4
    cols_avail = displaysize(io)[2]-2                                 # available cols in io (cannot write to all of it; subtract 2)
    cols_requi = sum(x->length(x)+3, irreplabels(BRS))+cols_irstart+ν_maxdigs+3 # required cols for irrep labels & band reps
    if cols_requi > cols_avail
        cols_toomany    = ceil(Int64, (cols_requi-cols_avail)/2) + 2  # +2 is to make room for '  …  ' extender
        cols_midpoint   = div(cols_requi-cols_irstart,2)+cols_irstart
        cols_skipmin    = cols_midpoint - cols_toomany
        cols_skipmax    = cols_midpoint + cols_toomany
        cols_eachstart  = [0; cumsum(length.(irreplabels(BRS)).+3)].+cols_irstart
        iridx_skiprange = [idx for (idx, col_pos) in enumerate(cols_eachstart) if cols_skipmin ≤ col_pos ≤ cols_skipmax]
        abbreviate = true
    else
        abbreviate = false
    end

    # print a "title" line and the irrep labels
    println(io, "$(length(BRS)) band representations", 
                " ($(isspinful(BRS) ? "spinful" : "spinless"))",
                " sampling $(Nirreps) irreps:")
    print(io, " "^(cols_irstart-1),'║'); # align with spaces
    for (iridx,lab) in enumerate(irreplabels(BRS)) # irrep labels
        if abbreviate && iridx ∈ iridx_skiprange
            if iridx == first(iridx_skiprange)
                print(io, "\b  …  ")
            end
        else
            print(io, ' ', lab, " │")
        end
    end
    println(io, ' '^ν_maxdigs, "ν", " ║") # band-filling column header
    #println(io)
    # print each bandrep
    for (bridx,BR) in enumerate(reps(BRS))
        ν = dim(BR)
        print(io, "   ", label(BR),                      # bandrep label
                  " "^(cols_brlab-length(label(BR))), '║')
        for (iridx,x) in enumerate(vec(BR)) # vector representation of band rep
            if abbreviate && iridx ∈ iridx_skiprange
                if iridx == first(iridx_skiprange)
                    print(io, mod(bridx,4) == 0 ? "\b  …  " : "\b     ")
                end
            else
                print(io, "  ")
                !iszero(x) ? print(io, x) : print(io, '·')
                print(io, " "^(length(irreplabels(BRS)[iridx])-1), '│') # assumes we will never have ndigit(x) != 1
            end
        end
        
        print(io, ' '^(1+ν_maxdigs-ndigits(ν)), ν, " ║") # band-filling
        if bridx != length(BRS); println(io); end
    end
end