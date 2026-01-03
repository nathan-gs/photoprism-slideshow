{ pkgs, sbt, self, ... }:

sbt.lib.mkSbtDerivation {
  inherit pkgs;

  pname = "photoprism-slideshow";
  version = "0.2.5";

  depsSha256 = "sha256-purjtrp38Pwanvhbn7J4DlY9oxvDSic5GhYnXOyCtE8=";
  
  buildInputs = [ ];
  src = self;
  nativeBuildInputs = [ ];
  
  depsWarmupCommand = ''
    sbt 'managedClasspath; compilers'
  '';

  startScript = ''
    #!${pkgs.runtimeShell}

    exec ${pkgs.jdk25_headless}/bin/java ''${JAVA_OPTS:-} -cp "${
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
