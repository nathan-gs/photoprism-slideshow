name := "photoprism-slideshow"

version := "0.1.0"

scalaVersion := "3.3.0"

libraryDependencies ++=  Seq(
  "com.lihaoyi" %% "cask" % "0.9.1",
  "io.crashbox" %% "simplesql" % "0.2.2",
  "org.xerial" % "sqlite-jdbc" % "3.42.0.0",
  "com.lihaoyi" %% "scalatags" % "0.12.0"
)
