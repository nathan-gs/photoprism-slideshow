{ pkgs, sbt, self, ... }:

sbt.lib.mkSbtDerivation {
  inherit pkgs;

  pname = "photoprism-slideshow";
  version = "0.0.1";

  depsSha256 = "sha256-nH5Ppa7/t4D1nePni4V2msPi+aoriz5V+b6/+pjoCy0=";
  
  buildInputs = [ ];
  src = self;
  nativeBuildInputs = [ ];
  
  buildPhase = ''
    sbt assembly
  '';

  installPhase = "mkdir -p $out; cp target/scala-*/photoprism-slideshow-assembly-*.jar $out/photoprism-slideshow.jar";

}