@kwdef mutable struct WriteConstraint
    writeAsRead::Option{Bool} = nothing
    useEnumeratedValues::Option{Bool} = nothing
    range::Option{Tuple{ScaledNonNegativeInteger,ScaledNonNegativeInteger}} = nothing
end


