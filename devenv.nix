{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = [ pkgs.git pkgs.sbt ];

  # https://devenv.sh/scripts/
  scripts.sbt-run.exec = "sbt run";

  enterShell = ''
    sbt-run
  '';

  # https://devenv.sh/languages/
  # languages.nix.enable = true;
  languages.scala.enable = true;
  languages.scala.package = pkgs.scala_3;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
