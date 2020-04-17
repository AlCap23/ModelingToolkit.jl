"""
$(TYPEDEF)

An expression representing the application of a function to symbolic arguments.

# Fields
$(FIELDS)

# Examples

Operations can be built by application of most built-in mathematical functions
to other [`Expression`](@ref) instances:

```jldoctest
julia> using ModelingToolkit

julia> @variables x y;

julia> op1 = sin(x)
sin(x())

julia> typeof(op1.op)
typeof(sin)

julia> op1.args
1-element Array{Expression,1}:
 x()

julia> op2 = x + y
x() + y()

julia> typeof(op2.op)
typeof(+)

julia> op2.args
2-element Array{Expression,1}:
 x()
 y()
```
"""
struct Operation <: Expression
    """The function to be applied."""
    op::Function
    """The arguments the function is applied to."""
    args::Vector{Expression}
end

Base.isequal(x::Operation,y::Operation) =
    x.op == y.op && length(x.args) == length(y.args) && all(isequal.(x.args,y.args))
Base.isequal(::Operation, ::Number   ) = false
Base.isequal(::Number   , ::Operation) = false
Base.isequal(O::Operation, v::Variable ) = isequal(convert(Variable,O),v)
Base.isequal(v::Variable , O::Operation) = isequal(O,v)
Base.isequal(::Operation, ::Constant ) = false
Base.isequal(::Constant , ::Operation) = false

Base.show(io::IO, O::Operation) = print(io, convert(Expr, O))

# For inv
Base.convert(::Type{Operation}, x::Bool) = Operation(identity, Expression[Constant(x)])
Base.convert(::Type{Operation}, x::Number) = Operation(identity, Expression[Constant(x)])
Base.convert(::Type{Operation}, x::Operation) = x
Base.convert(::Type{Operation}, x::Expression) = Operation(identity, Expression[x])
Operation(x) = convert(Operation, x)
Base.Symbol(O::Operation) = Symbol(convert(Variable,O))
Base.convert(::Type{Symbol},O::Operation) = Symbol(convert(Variable,O))

#convert to Expr
Base.Expr(op::Operation) = simplified_expr(op)
Base.convert(::Type{Expr},x::Operation) = Expr(x)

# promotion
Base.promote_rule(::Type{<:Constant}, ::Type{<:Operation}) = Operation
Base.promote_rule(::Type{<:Operation}, ::Type{<:Constant}) = Operation

# Fix Sparse MatMul
Base.:*(A::SparseMatrixCSC{Operation,S}, x::StridedVector{Operation}) where {S} =
    (T = Operation; mul!(similar(x, T, A.m), A, x, true, false))
Base.:*(A::SparseMatrixCSC{Tx,S}, x::StridedVector{Operation}) where {Tx,S} =
    (T = LinearAlgebra.promote_op(LinearAlgebra.matprod, Operation, Tx); mul!(similar(x, T, A.m), A, x, true, false))
Base.:*(A::SparseMatrixCSC{Operation,S}, x::StridedVector{Tx}) where {Tx,S} =
    (T = LinearAlgebra.promote_op(LinearAlgebra.matprod, Operation, Tx); mul!(similar(x, T, A.m), A, x, true, false))

LinearAlgebra.lu(O::AbstractMatrix{<:Operation};kwargs...) = lu(O,Val(false);kwargs...)
