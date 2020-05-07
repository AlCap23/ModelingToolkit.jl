using Test
using Latexify
using ModelingToolkit

### Tips for generating latex tests:
### Latexify has an unexported macro:
###
### Latexify.@generate_test
###
### which generates a test using a given latexify function.
### For example:
###
### Latexify.@generate_test latexify([1, 2, 3], [4, 5, 6]; env=:mdtable)
###
### This puts a ready-made test in your clipboard which you can paste into the
### test file.
###
### Just be sure to remove all such macros before you commit a change since it
### will cause issues with Travis.

@parameters t σ ρ β
@variables x(t) y(t) z(t)
@derivatives D'~t

eqs = [D(x) ~ σ*(y-x)*D(x-y)/D(z),
       0 ~ σ*x*(ρ-z)/10-y,
       D(z) ~ x*y^(2//3) - β*z]

@test latexify(eqs) ==
raw"\begin{align}
\frac{dx(t)}{dt} =& \frac{\sigma \left( \mathrm{y}\left( t \right) - \mathrm{x}\left( t \right) \right) \frac{d\left(\mathrm{x}\left( t \right) - \mathrm{y}\left( t \right)\right)}{dt}}{\frac{dz(t)}{dt}} \\
0 =& \frac{\sigma \mathrm{x}\left( t \right) \left( \rho - \mathrm{z}\left( t \right) \right)}{10} - \mathrm{y}\left( t \right) \\
\frac{dz(t)}{dt} =& \mathrm{x}\left( t \right) \left( \mathrm{y}\left( t \right) \right)^{\frac{2}{3}} - \beta \mathrm{z}\left( t \right)
\end{align}
"

@parameters t p[1:3]
@variables u[1:3](t)
@derivatives D'~t

eqs = [D(u[1]) ~ p[3]*(u[2]-u[1]),
       0 ~ p[2]*p[3]*u[1]*(p[1]-u[1])/10-u[2],
       D(u[3]) ~ u[1]*u[2]^(2//3) - p[3]*u[3]]

@test latexify(eqs) ==
raw"\begin{align}
\frac{du_1(t)}{dt} =& p_3 \left( \mathrm{u_2}\left( t \right) - \mathrm{u_1}\left( t \right) \right) \\
0 =& \frac{p_2 p_3 \mathrm{u_1}\left( t \right) \left( p_1 - \mathrm{u_1}\left( t \right) \right)}{10} - \mathrm{u_2}\left( t \right) \\
\frac{du_3(t)}{dt} =& \mathrm{u_1}\left( t \right) \left( \mathrm{u_2}\left( t \right) \right)^{\frac{2}{3}} - p_3 \mathrm{u_3}\left( t \right)
\end{align}
"

eqs = [D(u[1]) ~ p[3]*(u[2]-u[1]),
       D(u[2]) ~ p[2]*p[3]*u[1]*(p[1]-u[1])/10-u[2],
       D(u[3]) ~ u[1]*u[2]^(2//3) - p[3]*u[3]]

sys = ODESystem(eqs)

@test latexify(sys.eqs) ==
raw"\begin{align}
\frac{du_1(t)}{dt} =& p_3 \left( \mathrm{u_2}\left( t \right) - \mathrm{u_1}\left( t \right) \right) \\
\frac{du_2(t)}{dt} =& \frac{p_2 p_3 \mathrm{u_1}\left( t \right) \left( p_1 - \mathrm{u_1}\left( t \right) \right)}{10} - \mathrm{u_2}\left( t \right) \\
\frac{du_3(t)}{dt} =& \mathrm{u_1}\left( t \right) \left( \mathrm{u_2}\left( t \right) \right)^{\frac{2}{3}} - p_3 \mathrm{u_3}\left( t \right)
\end{align}
"

@test latexify(sys) ==
raw"$\begin{align}
\frac{du_1(t)}{dt} =& p_3 \left( \mathrm{u_2}\left( t \right) - \mathrm{u_1}\left( t \right) \right) \\
\frac{du_2(t)}{dt} =& \frac{p_2 p_3 \mathrm{u_1}\left( t \right) \left( p_1 - \mathrm{u_1}\left( t \right) \right)}{10} - \mathrm{u_2}\left( t \right) \\
\frac{du_3(t)}{dt} =& \mathrm{u_1}\left( t \right) \left( \mathrm{u_2}\left( t \right) \right)^{\frac{2}{3}} - p_3 \mathrm{u_3}\left( t \right)
\end{align}
$"

@parameters t σ ρ β
@variables x(t) y(t) z(t)
@derivatives D'~t

eqs = [D(x) ~ σ*(y-x),
       D(y) ~ x*(ρ-z)-y,
       D(z) ~ x*y - β*z]

lorenz1 = ODESystem(eqs,name=:lorenz1)
lorenz2 = ODESystem(eqs,name=:lorenz2)

@variables a
@parameters γ
connections = [0 ~ lorenz1.x + lorenz2.y + a*γ]
connected = ODESystem(connections,t,[a],[γ],systems=[lorenz1,lorenz2])

Latexify.@generate_test latexify(connected)

@test latexify(connected) ==
raw"$\begin{align}
0 =& \mathrm{lorenz1.x}\left( t \right) + \mathrm{lorenz2.y}\left( t \right) + a \gamma \\
\frac{dlorenz1_+x(t)}{dt} =& lorenz1.\sigma \left( \mathrm{lorenz1.y}\left( t \right) - \mathrm{lorenz1.x}\left( t \right) \right) \\
\frac{dlorenz1_+y(t)}{dt} =& \mathrm{lorenz1.x}\left( t \right) \left( lorenz1.\rho - \mathrm{lorenz1.z}\left( t \right) \right) - \mathrm{lorenz1.y}\left( t \right) \\
\frac{dlorenz1_+z(t)}{dt} =& \mathrm{lorenz1.x}\left( t \right) \mathrm{lorenz1.y}\left( t \right) - lorenz1.\beta \mathrm{lorenz1.z}\left( t \right) \\
\frac{dlorenz2_+x(t)}{dt} =& lorenz2.\sigma \left( \mathrm{lorenz2.y}\left( t \right) - \mathrm{lorenz2.x}\left( t \right) \right) \\
\frac{dlorenz2_+y(t)}{dt} =& \mathrm{lorenz2.x}\left( t \right) \left( lorenz2.\rho - \mathrm{lorenz2.z}\left( t \right) \right) - \mathrm{lorenz2.y}\left( t \right) \\
\frac{dlorenz2_+z(t)}{dt} =& \mathrm{lorenz2.x}\left( t \right) \mathrm{lorenz2.y}\left( t \right) - lorenz2.\beta \mathrm{lorenz2.z}\left( t \right)
\end{align}
$"
