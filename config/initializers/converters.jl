import Base.convert

convert(::Type{Int},            v::SubString{String}) = parse(Int, v)
convert(::Type{Vector{Int}},    s::String) = map(x -> parse(Int, x), split(s, ","))
convert(::Type{String},         v::Void) = ""
