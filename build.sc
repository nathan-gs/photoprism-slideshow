import mill._, scalalib._

object PhotoprismSlideshowModule extends RootModule with ScalaModule {

  def scalaVersion = "3.3.0"

  def ivyDeps = Agg(
    ivy"com.lihaoyi::cask:0.9.1",
    ivy"io.crashbox::simplesql:0.2.2",
    ivy"org.xerial:sqlite-jdbc:3.42.0.0",
    ivy"com.lihaoyi::scalatags:0.12.0"
  )

  object test extends ScalaTests with TestModule.Utest{

    def ivyDeps = Agg(
      ivy"com.lihaoyi::utest::0.8.1",
      ivy"com.lihaoyi::requests::0.8.0",
    )
  }
}