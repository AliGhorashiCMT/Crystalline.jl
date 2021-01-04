# ===== CONSTANTS =====

# We include several axes settings; as a result, there are more than 32 point groups 
# under the 3D case, because some variations are "setting-degenerate" (but are needed
# to properly match all space group settings)
const PGS_NUM2IUC = (
    (["1"], ["m"]),                                           # 1D
    (["1"], ["2"], ["m"], ["mm2"], ["4"], ["4mm"], ["3"],     # 2D
     ["3m1", "31m"],       # C3v setting variations
     ["6"], ["6mm"]),
    (["1"], ["-1"], ["2"], ["m"], ["2/m"], ["222"], ["mm2"],  # 3D
     ["mmm"], ["4"], ["-4"], ["4/m"], ["422"], ["4mm"], 
     ["-42m", "-4m2"],     # D2d setting variations
     ["4/mmm"], ["3"], ["-3"],
     ["312", "321"],       # D3 setting variations  (hexagonal axes)
     ["3m1", "31m"],       # C3v setting variations (hexagonal axes)
     ["-31m", "-3m1"],     # D3d setting variations (hexagonal axes)
     ["6"], ["-6"], ["6/m"], ["622"], ["6mm"], 
     ["-62m", "-6m2"],     # D3h setting variations
     ["6/mmm"], ["23"], ["m-3"], ["432"], ["-43m"], ["m-3m"])
)
# a flat tuple-listing of all the iuc labels in PGS_NUM2IUC; sliced across dimensions
const PGS_IUCs = map(x->tuple(Iterators.flatten(x)...), PGS_NUM2IUC)
# a tuple of ImmutableDicts, giving maps from iuc label to point group number
const PGS_IUC2NUM = tuple([ImmutableDict([lab=>findfirst(x->lab∈x, PGS_NUM2IUC[D])
                           for lab in PGS_IUCs[D]]...) for D in (1,2,3)]...)
# The IUC notation for point groups can be mapped to the Schoenflies notation, but the 
# mapping is not one-to-one but rather one-to-many; e.g. 3m1 and 31m maps to C3v but 
# correspond to different axis orientations. 
# When there is a choice of either hexagonal vs. rhombohedral or unique axes b vs unique
# axes a/c we choose hexagonal and unique axes b, respectively.
const IUC2SCHOENFLIES_PGS = ImmutableDict(
    "1"     => "C1",   "-1"    => "Ci",
    "2"     => "C2",   "m"     => "Cs",   "2/m"   => "C2h",  # unique axes b setting
    "222"   => "D2",   "mm2"   => "C2v",  "mmm"   => "D2h",  "4"    => "C4",
    "-4"    => "S4",   "4/m"   => "C4h",  "422"   => "D4",   "4mm"  => "C4v", 
    "-42m"  => "D2d",  "-4m2"  => "D2d",  # D2d setting variations
    "4/mmm" => "D4h",  "3"     => "C3",   "-3"    => "C3i",  
    "312"   => "D3",   "321"   => "D3",   # D3 setting variations  (hexagonal axes)
    "3m1"   => "C3v",  "31m"   => "C3v",  # C3v setting variations (hexagonal axes)
    "-31m"  => "D3d",  "-3m1"  => "D3d",  # D3d setting variations (hexagonal axes)
    "6"     => "C6",   "-6"    => "C3h",  "6/m"   => "C6h",  "622"  => "D6", 
    "6mm"   => "C6v",  
    "-62m"  => "D3h", "-6m2"   => "D3h",  # D3h setting variations
    "6/mmm" => "D6h",  "23"    => "T",
    "m-3"   => "Th",   "432"   => "O",    "-43m"  => "Td",   "m-3m" => "Oh"
)


# ===== METHODS =====

# --- Notation ---
function pointgroup_iuc2num(iuclab::String, D::Integer)
    return get(PGS_IUC2NUM[D], iuclab, nothing)
end
schoenflies(pg::PointGroup) = IUC2SCHOENFLIES_PGS[iuc(pg)]

# --- Point groups & operators ---
unmangle_pgiuclab(iuclab) = replace(iuclab, "/"=>"_slash_")

function read_pgops_xyzt(iuclab::String, ::Val{D}=Val(3)) where D
    D ∉ (1,2,3) && _throw_invaliddim(D)
    iuclab ∉ PGS_IUCs[D] && throw(DomainError(iuclab, "iuc label not found in database (see possible labels in PGS_IUCs[D])"))

    filepath = (@__DIR__)*"/../data/pgops/"*string(D)*"d/"*unmangle_pgiuclab(iuclab)*".json"
    ops_str = open(filepath) do io
        JSON2.read(io)
    end
    return ops_str
end
read_pgops_xyzt(iuclab::String, D::Integer) = read_pgops_xyzt(iuclab, Val(D))

@inline function pointgroup(iuclab::String, Dᵛ::Val{D}=Val(3)) where D
    D ∉ (1,2,3) && _throw_invaliddim(D)
    pgnum = pointgroup_iuc2num(iuclab, D) # this is not generally a particularly well-established numbering
    ops_str = read_pgops_xyzt(iuclab, Dᵛ)
    
    return PointGroup{D}(pgnum, iuclab, SymOperation{D}.(ops_str))
end
@inline pointgroup(iuclab::String, D::Integer) = pointgroup(iuclab, Val(D))

@inline function pointgroup_num2iuc(pgnum::Integer, Dᵛ::Val{D}, setting::Integer) where D
    @boundscheck 1 ≤ pgnum ≤ length(PGS_NUM2IUC[D]) || throw(DomainError(pgnum, "invalid pgnum; out of bounds of Crystalline.PGS_NUM2IUC"))
    iucs = @inbounds PGS_NUM2IUC[D][pgnum]
    @boundscheck 1 ≤ setting ≤ length(iucs) || throw(DomainError(setting, "invalid setting; out of bounds of Crystalline.PGS_NUM2IUC[pgnum]"))
    return @inbounds iucs[setting]
end
@inline function pointgroup(pgnum::Integer, Dᵛ::Val{D}=Val(3), setting::Int=1) where D
    D ∉ (1,2,3) && _throw_invaliddim(D)
    iuclab = pointgroup_num2iuc(pgnum, Dᵛ, setting)
    ops_str = read_pgops_xyzt(iuclab, Dᵛ)

    return PointGroup{D}(pgnum, iuclab, SymOperation{D}.(ops_str))
end
@inline pointgroup(pgnum::Integer, D::Integer, setting::Integer=1) = pointgroup(pgnum, Val(D), setting)

# --- POINT GROUPS VS SPACE & LITTLE GROUPS ---
function find_parent_pointgroup(g::AbstractGroup)
    # Note: this method will only find parent point groups with the same setting (i.e. 
    #       basis) as `g`. From a more general perspective, one might be interested in
    #       finding any isomorphic parent point group (but that is not achieved here; and is
    #       not a question with a unique answer either (e.g. PGs 2 and -1 are isomorphic)).
    D = dim(g)
    xyzt_pgops = sort!(xyzt.(pointgroup(g)))

    @inbounds for iuclab in PGS_IUCs[D]
        P = pointgroup(iuclab, D)
        if sort!(xyzt.(P)) == xyzt_pgops # the sorting/xyzt isn't strictly needed; belts & buckles...
            return P
        end
    end

    return nothing
end

# --- POINT GROUP IRREPS ---
# loads 3D point group data from the .jld2 file opened in `PGIRREPS_JLDFILE`
function _load_pgirreps_data(iuclab::String)
    jldgroup = PGIRREPS_JLDFILE[unmangle_pgiuclab(iuclab)] 
    matrices::Vector{Vector{Matrix{ComplexF64}}} = jldgroup["matrices"]
    realities::Vector{Int8}                      = jldgroup["realities"]
    cdmls::Vector{String}                        = jldgroup["cdmls"]

    return matrices, realities, cdmls
end

# 3D
"""
    get_pgirreps(iuclab::String, ::Val{D}=Val(3)) where D ∈ (1,2,3)
    get_pgirreps(iuclab::String, D)

Return the (crystallographic) point group irreps of the IUC label `iuclab` of dimension `D`
as a vector of `PGIrrep{D}`s.

## Notes
The irrep labelling follows the conventions of CDML [1] [which occasionally differ from
those in e.g. Bradley and Cracknell, *The Mathematical Theory of Symmetry in Solids* (1972)].

The data is sourced from the Bilbao Crystallographic Server [2]. If you are using this 
functionality in an explicit fashion, please cite the original reference [3].

## References
[1] Cracknell, Davies, Miller, & Love, Kronecher Product Tables 1 (1979).

[2] Bilbao Crystallographic Server: 
    https://www.cryst.ehu.es/cgi-bin/cryst/programs/representations_point.pl

[3] Elcoro et al., 
    [J. of Appl. Cryst. **50**, 1457 (2017)](https://doi.org/10.1107/S1600576717011712)
"""
function get_pgirreps(iuclab::String, ::Val{3}=Val(3))
    pg = pointgroup(iuclab, Val(3)) # operations

    matrices, realities, cdmls = _load_pgirreps_data(iuclab)
    
    return PGIrrep{3}.(cdmls, Ref(pg), matrices, Reality.(realities))
end
# 2D
function get_pgirreps(iuclab::String, ::Val{2})
    pg = pointgroup(iuclab, Val(2)) # operations

    # Because the operator sorting and setting is identical* between the shared point groups
    # of 2D and 3D, we can just do a whole-sale transfer of shared irreps from 3D to 2D.
    # (*) Actually, "2" and "m" have different settings in 2D and 3D; but they just have two
    #     operators and irreps each, so the setting difference doesn't matter.
    #     That the settings and sorting indeed agree between 2D and 3D is tested in 
    #     scripts/compare_pgops_3dvs2d.jl
    matrices, realities, cdmls = _load_pgirreps_data(iuclab)
    
    return PGIrrep{2}.(cdmls, Ref(pg), matrices, Reality.(realities))
end
# 1D
function get_pgirreps(iuclab::String, ::Val{1})
    pg = pointgroup(iuclab, Val(1))
    # Situation in 1D is sufficiently simple that we don't need to bother with loading from 
    # a disk; just branch on one of the two possibilities
    if iuclab == "1"
        matrices = [[fill(one(ComplexF64), 1, 1)]]
        cdmls    = ["Γ₁"]
    elseif iuclab == "m"
        matrices = [[fill(one(ComplexF64), 1, 1),  fill(one(ComplexF64), 1, 1)], # even
                    [fill(one(ComplexF64), 1, 1), -fill(one(ComplexF64), 1, 1)]] # odd
        cdmls    = ["Γ₁", "Γ₂"]
    else
        throw(DomainError(iuclab, "invalid 1D point group IUC label"))
    end
    return PGIrrep{1}.(cdmls, Ref(pg), matrices, REAL)
end
get_pgirreps(iuclab::String, ::Val{D}) where D = _throw_invaliddim(D) # if D ∉ (1,2,3)
get_pgirreps(iuclab::String, D::Integer)  = get_pgirreps(iuclab, Val(D))
function get_pgirreps(pgnum::Integer, Dᵛ::Val{D}=Val(3), setting::Integer=1) where D
    iuc = pointgroup_num2iuc(pgnum, Dᵛ, setting)
    return get_pgirreps(iuc, Dᵛ)
end
get_pgirreps(pgnum::Integer, D::Integer, setting::Integer=1) = get_pgirreps(pgnum, Val(D), setting)