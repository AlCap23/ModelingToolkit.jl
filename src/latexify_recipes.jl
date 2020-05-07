@latexrecipe function f(eqs::Vector{ModelingToolkit.Equation})
    # Set default option values.
    env --> :align
    cdot --> false

    # Convert both the left and right hand side to expressions of basic types
    # that latexify can deal with.

    rhs = getfield.(eqs, :rhs)
    rhs = convert.(Expr, rhs)
    rhs = [postwalk(x -> x isa ModelingToolkit.Constant ? x.value : x, eq) for eq in rhs]
    rhs = [postwalk(x -> x isa Expr && length(x.args) == 1 ? x.args[1] : x, eq) for eq in rhs]
    rhs = [postwalk(x -> x isa Symbol ? reparse(x) : x, eq) for eq in rhs]
    rhs = [postwalk(x -> x isa Expr && x.args[1] == :derivative && length(x.args[2].args) == 2 ? :($(Symbol(:d, x.args[2]))/($(Symbol(:d, x.args[2].args[2])))) : x, eq) for eq in rhs]
    rhs = [postwalk(x -> x isa Expr && x.args[1] == :derivative ? "\\frac{d\\left($(Latexify.latexraw(x.args[2]))\\right)}{d$(Latexify.latexraw(x.args[3]))}" : x, eq) for eq in rhs]

    lhs = getfield.(eqs, :lhs)
    lhs = convert.(Expr, lhs)
    lhs = [postwalk(x -> x isa ModelingToolkit.Constant ? x.value : x, eq) for eq in lhs]
    lhs = [postwalk(x -> x isa Expr && length(x.args) == 1 ? x.args[1] : x, eq) for eq in lhs]
    lhs = [postwalk(x -> x isa Symbol ? reparse(x) : x, eq) for eq in lhs]
    @show lhs
    lhs = [postwalk(x -> x isa Expr && x.args[1] == :derivative && length(x.args[2].args) == 2 ? :($(Symbol(:d, string(x.args[2])))/($(Symbol(:d, x.args[2].args[2])))) : x, eq) for eq in lhs]
    @show lhs
    lhs = [postwalk(x -> x isa Expr && x.args[1] == :derivative ? "\\frac{d\\left($(Latexify.latexraw(x.args[2]))\\right)}{d$(Latexify.latexraw(x.args[3]))}" : x, eq) for eq in lhs]

    return lhs, rhs
end

function add_d(s)
    out = Meta.parse(str)
    if out isa Symbol
        return Symbol(:d,out)
    else
        return Symbol(str)
    end
end

@latexrecipe function f(sys::ModelingToolkit.AbstractSystem)
    return latexify(equations(sys))
end
