__precompile__()

module PhantomJS

export renderhtml, execjs

const phantomjspath = joinpath(dirname(@__FILE__),
                               "../deps/usr/bin/phantomjs")

"""
Function `execjs(jsscript::String)` executes script `jsscript` in Phantomjs.
"""
function execjs(jsscript::String)
  mktempdir() do tdir
    jspath = joinpath(tdir, randstring() * ".js")
    open(io -> write(io, jsscript), jspath, "w")

    run(`$phantomjspath $jspath`)
  end

  nothing
end





"""
Function `renderhtml(source::IO; kwargs...)` loads the html provided in argument
`source` and returns the page capture in a `Vector{UInt8}`

Keyword arguments are :

`format` (String, default "png") : output format, possible values are "png",
"jpeg", "pdf", "bmp", "ppm" and "gif"
`width` & `height` (Int) : simulated size of view used for the layout, in pixels.
And output size except if `format` = "pdf" or if `smartSize` is `true`.
`clipToSelector` (String) : if set, the capture will be cropped to the element
identified by the selector
`quality` (Int, default 75) : quality setting for compressed formats (jpeg and
  png)
`background` (String, default `white`) : background color for image, set to
"transparent" if you do not want any color

Pdf format only :
`paperSize` (String, default "A4") : possible values are
"A3", "A4", "A5", "Legal", "Letter", "Tabloid"
`orientation` (String, default "portait") : possible values are
"portrait", "landscape"
`margin` (String or Int, default "0") : Supported dimension units are: 'mm',
'cm', 'in', 'px'. No unit means 'px'.


"""
function renderhtml(source::IO;
                    format::String="png",
                    width::Int=1024,
                    height::Int=800,
                    clipToSelector::String="",
                    quality::Int=75,
                    paperSize::String="A4",
                    orientation::String="portrait",
                    margin::Union{String, Int}=0,
                    background::String="white")

  local result

  mktempdir() do tdir
    htmlpath = joinpath(tdir, randstring() * ".html")
    open(io -> write(io, read(source)), htmlpath, "w")
    htmlpath = replace(htmlpath, "\\", "/")

    destpath = joinpath(tdir, randstring() * ".png")
    destpath = replace(destpath, "\\", "/")

    bgjs = background == "transparent" ? "" :
             """page.evaluate(function() {
                  document.body.bgColor = '$background';
                });
             """

    clipjs = clipToSelector == "" ? "" :
               """
                var clipRect = page.evaluate(function(){
                    return document.querySelector('$clipToSelector').getBoundingClientRect();
                  });

                page.clipRect = {
                  top:    clipRect.top,
                  left:   clipRect.left,
                  width:  clipRect.width,
                  height: clipRect.height
                };
               """

    jsscript = """
      "use strict";
      var page = require('webpage').create(),
          system = require('system'),
          address, output, size, pageWidth, pageHeight;

      address = 'file:///$htmlpath';
      output = '$destpath';

      page.viewportSize = { width: $width, height: $height };

      page.paperSize = { format: '$paperSize',
                         orientation: '$orientation',
                         margin: '$margin' };

      page.open(address, function (status) {
          if (status !== 'success') {
              console.log('Unable to load the address : ' + address);
              phantom.exit(1);
          } else {
              window.setTimeout(function () {
                  $bgjs
                  $clipjs
                  page.render(output,
                              {format: '$format',
                               quality: '$quality'});
                  phantom.exit();
              }, 200);
          }
      });
    """

    jspath = joinpath(tdir, randstring() * ".js")
    open(io -> write(io, jsscript), jspath, "w")

    run(`$phantomjspath $jspath`)
    result = read(destpath)
  end

  result
end






end # module
