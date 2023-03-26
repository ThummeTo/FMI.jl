using PkgEval
using FMI

config = Configuration(; julia="1.8");

package = Package(; name="FMI");

@info "PkgEval"
result = evaluate([config], [package])

@info "Result"
println(result)

@info "Log"
println(result["log"])