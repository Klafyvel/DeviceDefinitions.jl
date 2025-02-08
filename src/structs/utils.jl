const Option{T} = Union{Some{T},Nothing}
Base.convert(::Type{Option{T}}, x) where T = Some(x)
