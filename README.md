# PhantomJS

|Julia package | master tests (on nightly + release) | Coverage |
|:--------:|:-----------------------------:|:-----------:|
|[![PhantomJS](http://pkg.julialang.org/badges/PhantomJS_0.5.svg)](http://pkg.julialang.org/?pkg=PhantomJS&ver=0.5) | [![Build Status](https://travis-ci.org/fredo-dedup/PhantomJS.jl.svg?branch=master)](https://travis-ci.org/fredo-dedup/PhantomJS.jl) | [![Coverage Status](https://coveralls.io/repos/fredo-dedup/PhantomJS.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/fredo-dedup/PhantomJS.jl?branch=master) |
|[![PhantomJS](http://pkg.julialang.org/badges/PhantomJS_0.6.svg)](http://pkg.julialang.org/?pkg=PhantomJS&ver=0.6) | [![Build status](https://ci.appveyor.com/api/projects/status/ehm93gewha4355cg?svg=true)](https://ci.appveyor.com/project/fredo-dedup/phantomjs-jl) | [![codecov.io](http://codecov.io/github/fredo-dedup/PhantomJS.jl/coverage.svg?branch=master)](http://codecov.io/github/fredo-dedup/PhantomJS.jl?branch=master) |


This package provides access to the PhantomJS headless browser (http://phantomjs.org/).
The main use case is to have access to a platform that can process complex html
files, including javascript code, to produce JPEG, PNG, etc.. images or PDF files.
But the other uses such as website testing and page automation are of course still
possible.

The current Julia API is minimal. So all suggestions and PR are all the more welcome.

Exported functions are :
- `execjs(jsscript::String)` : to execute the given script within PhantomJS

example : Showing the version of PhantomJS
```
PhantomJS.execjs(
"""
  "use strict";
  console.log('using PhantomJS version ' +
    phantom.version.major + '.' +
    phantom.version.minor + '.' +
    phantom.version.patch);
  phantom.exit();
""")

```

- `renderhtml(source::IO; kwargs...)` : to render the html page given by source
to an image or a pdf (returned as a `Vector{UInt8}`). Type `? renderhtml` to see
 all the rendering options.

example, converting an HMTL file to a pdf :
```
open(*html file path*) do io
  ret = renderhtml(io, format="pdf")
  open(io -> write(io, ret), *output file path*, "w")
end
```
