using PkgEval
using FMI
using Test

config = Configuration(; julia = "1.10", time_limit = 120 * 60);

package = Package(; name = "FMI");

@info "PkgEval"
result = evaluate([config], [package])

@info "Result"
println(result)

@info "Log"
println(result[1, :log])

@test result[1, :status] == :ok
