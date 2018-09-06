"""
    CircShiftedArray(parent::AbstractArray, shifts)

Custom `AbstractArray` object to store an `AbstractArray` `parent` circularly shifted by `shifts` steps (where `shifts` is
a `Tuple` with one `shift` value per dimension of `parent`).
Use `copy` to collect the values of a `CircShiftedArray` into a normal `Array`.

# Examples

```jldoctest circshiftedarray
julia> v = [1, 3, 5, 4];

julia> s = CircShiftedArray(v, (1,))
4-element ShiftedArrays.CircShiftedArray{Int64,1,Array{Int64,1}}:
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
    shifts::NTuple{N, Int64}
    function CircShiftedArray(p::AbstractArray{T, N}, n = Tuple(0 for i in 1:N)) where {T, N}
        @assert all(step(x) == 1 for x in Compat.axes(p))
        new{T, N, typeof(v)}(p, _padded_tuple(p, n))
    end
end

"""
    CircShiftedVector{T, S<:AbstractArray}

Shorthand for `CircShiftedArray{T, 1, S}`.
"""
const CircShiftedVector{T, S<:AbstractArray} = CircShiftedArray{T, 1, S}

CircShiftedVector(v::AbstractVector, n = (0,)) = CircShiftedArray(v, n)

Base.size(s::CircShiftedArray) = Base.size(parent(s))


function get_circshifted_index(ind, shift, range)
    a, b = extrema(range)
    n = length(range)
    while ind < a
        ind += n
    end
    while ind > b
        ind -= n
    end
    ind
end

function Base.getindex(s::CircShiftedArray{T, 1, S}, x::Int) where {T, S<:AbstractArray}
    v = parent(s)
    i = get_circshifted_index(x, shifts(s), Compat.axes(v)[1])
    v[i...]
end

# function Base.getindex(s::CircShiftedArray{T, N, S}, x::Vararg{Int, N}) where {T, N, S<:AbstractArray}
#     v = parent(s)
#     i = map(get_circshifted_index, x, shifts(s), Compat.axes(v))
#     v[i...]
# end

function Base.setindex!(s::CircShiftedArray{T, N, S}, el, x::Vararg{Int, N}) where {T, N, S<:AbstractArray}
    v = parent(s)
    i = map(get_circshifted_index, x, shifts(s), Compat.axes(v))
    v[i...] = el
end

Base.parent(s::CircShiftedArray) = s.parent

"""
    shifts(s::CircShiftedArray)

Returns amount by which `s` is shifted compared to `parent(s)`.
"""
shifts(s::CircShiftedArray) = s.shifts

Base.checkbounds(::CircShiftedArray, I...) = nothing
