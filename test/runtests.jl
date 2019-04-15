using PhantomJS
using Base.Test

# execjs test

execjs("""
  "use strict";
  console.log('using PhantomJS version ' +
    phantom.version.major + '.' +
    phantom.version.minor + '.' +
    phantom.version.patch);
  phantom.exit();
  """)

# renderhtml test

src = joinpath(dirname(@__FILE__), "../examples/Example Domain.html")

io = open(src)
ret = renderhtml(io, format="pdf")
close(io)

@test isa(ret, Vector{UInt8} )
@test length(ret) > 10000
