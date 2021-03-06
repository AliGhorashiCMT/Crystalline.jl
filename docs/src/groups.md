# Groups
All groups in Crystalline are concrete instances of the abstract supertype [`AbstractGroup{D}`](@ref), referring to a group in `D` dimensions. `AbstractGroup{D}` is itself a subtype of `AbstractVector{SymOperation{D}}`.
Crystalline currently supports four group types: [`SpaceGroup`](@ref), [`LittleGroup`](@ref), [`PointGroup`](@ref), and [`SiteGroup`](@ref).

## Space groups

The one, two, and three-dimensional space groups are accessible via [`spacegroup`](@ref), which takes the space group number `sgnum` and dimensino `D` as input (ideally, the dimension is provided as a `Val{D}` for the sake of type stability) and returns a `SpaceGroup{D}` structure:
```@example spacegroup
using Crystalline

D     = 3  # dimension
sgnum = 16 # space group number (≤2 in 1D, ≤17 in 2D, ≤230 in 3D)
sg    = spacegroup(sgnum, D) # where practical, `spacegroup` should be called with a `Val{D}` dimension to ensure type stability; here we have D::Int instead for simplicity
```
By default, the returned operations are given in the conventional setting of the International Tables of Crystallography, Volume A (ITA). Conversion to the standard primitive lattices can be accomplished via [`primitive`](@ref).

### Multiplication tables
We can compute the multiplication table of a space group (under the previously defined notion of operator composition) using [`MultTable`](@ref):
```@example spacegroup
MultTable(sg)
```

### Symmorphic vs. nonsymorphic space groups
A given space group can be tested for whether or not it is symmorphic via [`issymmorph`](@ref).