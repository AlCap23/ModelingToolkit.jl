using ModelingToolkit
using LinearAlgebra
using SparseArrays: sparse
using Test

@variables a,b,c,d,e,f,g,h,i

# test hashing
aa = a; # old a

@variables a

@test isequal(a, aa)
@test hash(a) == hash(aa)

@test isequal(get_variables(a+aa+1), [a])

@test hash(a+b ~ c+d) == hash(a+b ~ c+d)

# test some matrix operations don't throw errors
X = [0 b c; d e f; g h i]
@test iszero(simplify(det(X) - ((b * f * g) + (c * d * h) - (b * d * i) - (c * e * g)), polynorm=true))
F = lu(X)
R = simplify.(F.L * F.U - X[F.p, :], polynorm=true)
@test iszero(R)
@test simplify.(F \ X, polynorm=true) == I
inv(X)
qr(X)

# test operations with sparse arrays and Operations
# note `isequal` instead of `==` because `==` would give another Operation

# test that we can create a sparse array of Operation
Oarray = zeros(Num, 2,2)
Oarray[2,2] = a
@test isequal(sparse(Oarray), sparse([2], [2], [a]))

# test Operation * sparse
@test isequal(a * sparse([2], [2], [1]), sparse([2], [2], [a * 1]))

# test sparse{Operation} + sparse{Operation}
A = sparse([2], [2], [a])
B = sparse([2], [2], [b])
@test isequal(A + B, sparse([2], [2], [a+b]))

# test sparse{Operation} * sparse{Operation}
C = sparse([1, 2], [2, 1], [c, c])
D = sparse([1, 2], [2, 1], [d, d])

@test isequal(C * D, sparse([1,2], [1,2], [c * d, c * d]))

@parameters t σ ρ β
@variables x(t) y(t) z(t)
@derivatives D'~t Dx'~x Dy'~y Dz'~z
eqs = [D(x) ~ σ*(y-x),
       D(y) ~ x*(ρ-z)-y,
       D(z) ~ x*y - β*z]
J = Num[Dx(eqs[1].rhs) Dy(eqs[1].rhs) Dz(eqs[1].rhs)
 Dx(eqs[2].rhs) Dy(eqs[2].rhs) Dz(eqs[2].rhs)
 Dx(eqs[3].rhs) Dy(eqs[3].rhs) Dz(eqs[3].rhs)]

J = expand_derivatives.(J)
using LinearAlgebra
luJ = lu(J,Val(false))

using ModelingToolkit
@variables M[1:2,1:2]
inv(M)

@variables b[1:2]
M = [1 0; 0 2]
M \ b
M \ reshape(b,2,1)
M = [1 1; 0 2]
M \ reshape(b,2,1)


M = [1 a; 0 2]
M \ b
M \ [1, 2]
