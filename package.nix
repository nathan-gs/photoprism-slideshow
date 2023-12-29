{ pkgs, sbt, self, ... }:

sbt.lib.mkSbtDerivation {
  inherit pkgs;

  pname = "photoprism-slideshow";
  version = "0.1.1";

  depsSha256 = "sha256-qwtUYKy51TFA/q/Yd2bwzrPSkA/Xjrsbb8ftQf/0PlM=";
  
  buildInputs = [ ];
  src = self;
  nativeBuildInputs = [ ];
  
  depsWarmupCommand = ''
    sbt 'managedClasspath; compilers'
  '';

  startScript = ''
    #!${pkgs.runtimeShell}

    exec ${pkgs.openjdk_headless}/bin/java ''${JAVA_OPTS:-} -cp "${
      placeholder "out"
    }/share/photoprism-slideshow/lib/*" photoprism.slideshow.PhotoprismSlideshowApp "$@"
  '';

  buildPhase = ''
    sbt stage
  '';

  installPhase = ''
    libs_dir="$out/share/photoprism-slideshow/lib"
    mkdir -p "$libs_dir"
    cp -ar target/universal/stage/lib/. "$libs_dir"

    install -T -D -m755 $startScriptPath $out/bin/photoprism-slideshow
  '';

  passAsFile = ["startScript"];

}