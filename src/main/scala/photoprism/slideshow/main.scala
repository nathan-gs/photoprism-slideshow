package photoprism.slideshow

import simplesql as sq
import photoprism.slideshow.domain._


object PhotoprismSlideshowApp extends cask.MainRoutes{
  val ds: javax.sql.DataSource = {
      val ds = org.sqlite.SQLiteDataSource()
      ds.setUrl("jdbc:sqlite:./index.db")
      ds
  }

  def asJson[T:upickle.default.Writer](a: T) = {
    cask.Response(upickle.default.write(a), headers = Seq("Content-Type" -> "application/json"))
  }

  @cask.get("/")
  def index() = cask.Redirect("/static/index.html")


  @cask.staticFiles("/static")
  def static() = "src/main/resources/"

  @cask.get("/albums")
  def albums() = {
    sq.transaction(ds){
      val l = sq.read[Album](sql"""
          select album_uid, album_title, album_type, album_category 
          from albums 
          WHERE 
          album_type = 'album' AND album_category = 'Travel' 
          ORDER BY album_title ASC""")
      asJson(l)
    }
  }

  @cask.get("/photos/:albumUid")
  def photos(albumUid: String) = {
    sq.transaction(ds){
      asJson(sq.read[Photo](sql"""
          select p.photo_uid, p.photo_title, p.photo_type, f.file_hash
          from files f
          INNER JOIN photos p ON p.photo_uid = f.photo_uid
          INNER JOIN photos_albums pa ON pa.photo_uid = p.photo_uid
          WHERE pa.album_uid = ${albumUid} AND p.photo_type = 'image'                
          """))
    }
  }

  @cask.post("/do-thing")
  def doThing(request: cask.Request) = {
    request.text().reverse
  }

  @cask.get("/do-thing2")
  def doThing2(request: cask.Request) = {
    request.text().reverse
  }

  override def debugMode = true

  override def host = "0.0.0.0"

  initialize()
}
