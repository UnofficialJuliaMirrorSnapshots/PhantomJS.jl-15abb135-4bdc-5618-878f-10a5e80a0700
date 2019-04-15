using BinDeps

@BinDeps.setup

@static if is_apple()
  ostype = "apple"
  elseif is_windows()
    ostype = "windows"
  elseif is_linux()
    ostype = "linux"
  else
    error("No wkhtmltox library available for this OS")
  end

ostype *= Int==Int64 ? "64" : "32"

ver = "2.1.1"

archivemap = Dict(
 "apple32"   => "-macosx.zip",
 "windows32" => "-windows.zip",
 "linux32"   => "-linux-i686.tar.bz2",
 "apple64"   => "-macosx.zip",
 "windows64" => "-windows.zip",
 "linux64"   => "-linux-x86_64.tar.bz2",
 )

url = "https://cnpmjs.org/downloads/phantomjs-$ver" * archivemap[ostype]
downloadname = basename(url)

exemap = Dict(
 "apple32"   => "phantomjs-$ver-macosx/bin/phantomjs",
 "windows32" => "phantomjs-$ver-windows/bin/phantomjs.exe",
 "linux32"   => "phantomjs-$ver-linux-i686/bin/phantomjs",
 "apple64"   => "phantomjs-$ver-macosx/bin/phantomjs",
 "windows64" => "phantomjs-$ver-windows/bin/phantomjs.exe",
 "linux64"   => "phantomjs-$ver-linux-x86_64/bin/phantomjs",
 )

exepath = exemap[ostype]
exefile = basename(exepath)

destdir      = joinpath(dirname(@__FILE__), "usr/bin")
unzipdir     = joinpath(dirname(@__FILE__), "src")
downloadsdir = joinpath(dirname(@__FILE__), "downloads")

type FileCopyRule <: BinDeps.BuildStep
    src::AbstractString
    dest::AbstractString
end
Base.run(fc::FileCopyRule) = isfile(fc.dest) || cp(fc.src, fc.dest)

type MakeExeRule <: BinDeps.BuildStep
    path::AbstractString
end
Base.run(rule::MakeExeRule) = chmod(rule.path, 0o755)


run(@build_steps begin
      CreateDirectory(downloadsdir, true)
      CreateDirectory(unzipdir, true)
      CreateDirectory(destdir, true)
      @build_steps FileRule( [joinpath(destdir, exefile)],
          @build_steps begin
            FileDownloader(url, joinpath(downloadsdir, downloadname))
            FileUnpacker(joinpath(downloadsdir, downloadname), unzipdir, exepath)
            FileCopyRule(joinpath(unzipdir,exepath), joinpath(destdir,exefile))
            MakeExeRule(joinpath(destdir,exefile))
          end )
      end)
