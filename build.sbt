name := "photoprism-slideshow"

version := "0.2.1"

scalaVersion := "3.3.3"

libraryDependencies ++=  Seq(
  "com.lihaoyi" %% "cask" % "0.9.1",
  "io.crashbox" %% "simplesql" % "0.3.0",
  "org.xerial" % "sqlite-jdbc" % "3.42.0.0",
  "com.mysql" % "mysql-connector-j" % "9.0.0",
  "com.lihaoyi" %% "scalatags" % "0.12.0"
)

enablePlugins(JavaAppPackaging)