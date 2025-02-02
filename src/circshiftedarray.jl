"""
    CircShiftedArray(parent::AbstractArray, shifts)

Custom `AbstractArray` object to store an `AbstractArray` `parent` circularly shifted by `shifts` steps (where `shifts` is
a `Tuple` with one `shift` value per dimension of `parent`). Note that `shift` is modified with a modulo operation and does
not store the passed value but instead a positive number which leads to an equivalent shift.
Use `copy` to collect the values of a `CircShiftedArray` into a normal `Array`.

# Examples

```jldoctest circshiftedarray
julia> v = [1, 3, 5, 4];

julia> s = CircShiftedArray(v, (1,))
4-element CircShiftedArray{Int64,1,Array{Int64,1}}:
 4
 1
 3
 5

julia> copy(s)
4-element Array{Int64,1}:
 4
 1
 3
 5
```
"""
struct CircShiftedArray{T, N, S<:AbstractArray} <: AbstractArray{T, N}
    parent::S
    # shift stores the circshift but is modified with mod (see below) to be more efficient
    # in the getindex method
    # negative shifts (left shift) are converted to positive (right shifts) with a larger
    # shift number
    shifts::NTuple{N, Int}
    function CircShiftedArray(p::AbstractArray{T, N}, n = Tuple(0 for i in 1:N)) where {T, N}
        @assert all(step(x) == 1 for x in axes(p))
        # n could be a huge shift number, reduce it by taking the mod
        # shift is also positive due to this mod
        n = map(mod, _padded_tuple(p, n), size(p))
        new{T, N, typeof(p)}(p, n)
    end
end

"""
    CircShiftedVector{T, S<:AbstractArray}

Shorthand for `CircShiftedArray{T, 1, S}`.
"""
const CircShiftedVector{T, S<:AbstractArray} = CircShiftedArray{T, 1, S}

CircShiftedVector(v::AbstractVector, n = (0,)) = CircShiftedArray(v, n)

size(s::CircShiftedArray) = size(parent(s))

@inline function bringwithin(ind_with_offset::Int, ranges::AbstractUnitRange)
    return ifelse(ind_with_offset < first(ranges), ind_with_offset + length(ranges), ind_with_offset)
end

@inline function getindex(s::CircShiftedArray{T, N}, x::Vararg{Int, N}) where {T, N}
    v = parent(s)
    @boundscheck checkbounds(v, x...)
    ind = offset(shifts(s), x)
    i = map(bringwithin, ind, axes(s))
    @inbounds ret = v[i...]
    ret
end

@inline function setindex!(s::CircShiftedArray{T, N}, el, x::Vararg{Int, N}) where {T, N}
    v = parent(s)
    @boundscheck checkbounds(v, x...)
    ind = offset(shifts(s), x)
    i = map(bringwithin, ind, axes(s))
    @inbounds v[i...] = el
end

parent(s::CircShiftedArray) = s.parent

"""
    shifts(s::CircShiftedArray)

Returns amount by which `s` is shifted compared to `parent(s)`.
"""
shifts(s::CircShiftedArray) = s.shifts
