# ShiftedArrays

[![Build Status](https://travis-ci.org/piever/ShiftedArrays.jl.svg?branch=master)](https://travis-ci.org/piever/ShiftedArrays.jl)

[![codecov.io](http://codecov.io/github/piever/ShiftedArrays.jl/coverage.svg?branch=master)](http://codecov.io/github/piever/ShiftedArrays.jl?branch=master)

Implementation of shifted arrays. Work in progress.

## Shifting the data

Two operation are provided for lazily shifting vectors: `lag` and `lead`.

```julia
julia> v = [1, 3, 5, 4];

julia> lag(v)
4-element ShiftedArrays.ShiftedArray{Int64,1,Array{Int64,1}}:
  missing
 1       
 3       
 5       

julia> v .- lag(v) # compute difference from previous element without unnecessary allocations
4-element Array{Any,1}:
   missing
  2       
  2       
 -1       

julia> s = lag(v, 2) # shift by more than one element
4-element ShiftedArrays.ShiftedArray{Int64,1,Array{Int64,1}}:
  missing
  missing
 1       
 3
```

Use `copy` to collect the shifted data into an `Array`:

```julia
julia> copy(s)
4-element Array{Union{Int64, Missings.Missing},1}:
  missing
  missing
 1       
 3
```

`lead` is the analogous of `lag` but shifts in the opposite direction:

```julia
julia> v = [1, 3, 5, 4];

julia> lead(v)
4-element ShiftedArrays.ShiftedArray{Int64,1,Array{Int64,1}}:
 3       
 5       
 4       
  missing
```
