package photoprism.slideshow

import simplesql as sq
import photoprism.slideshow.domain._
import java.sql.DriverManager
import scalatags.Text.all._


object PhotoprismSlideshowApp extends cask.MainRoutes{

  val dsn = scala.util.Properties.envOrElse("DSN", "")
  val basePath = scala.util.Properties.envOrElse("BASE_PATH", "")
  val interval = scala.util.Properties.envOrElse("INTERVAL", "10").toInt
  val photoprismUrl = scala.util.Properties.envOrElse("PHOTOPRISM_URL", "")
  val sqlRandomFunction = {
    if (dsn.contains("mysql"))
      "RAND()"
    else
      "RANDOM()"
  }

  val ds = new sq.DataSource(() => sq.Connection(DriverManager.getConnection(dsn)))

  @cask.get(s"$basePath")
  def index() = {
    cask.Response(
      doctype("html")(
        html(
          head(
            tag("title")(s"Photoprism Slideshow"),
            tag("style")(raw(s"""
              body, html {
                margin: 0;
                padding: 0;
                height: 100%;
                overflow: hidden;
              }         
              #photo {
                background-color: grey;
                background-position-x: center;
                background-position-y: top;
                background-repeat: no-repeat;
                background-attachment: fixed;
                background-size: auto;
                background-origin: padding-box;
                background-clip: border-box;
                height: 100%;
                background-size: contain;
              }  
              #box {
                position: absolute;
                bottom: 10px;
                left: 150px;
                right: 0;
                color: white;
                padding: 1em;
                font-family: sans-serif;
                z-index: 1000;
              }   
              """)),
            meta(name:="viewport", content:="width=device-width, initial-scale=1"),
            script(src:="https://cdnjs.cloudflare.com/ajax/libs/nosleep/0.12.0/NoSleep.min.js")
          ),
          body(
            div(id:="photo")(
              div(id:="box")(
                h1(id:="title","test"),
                p(id:="ts","test")
              )
            ),
            tag("script")(raw(s"""
              
              function refreshImage() {
                fetch('./photo/random/' + location.hash.substr(1))
                .then(function(response) {
                  if (response.status !== 200) {
                    console.log('Looks like there was a problem. Status Code: ' + response.status);
                    return;
                  }

                  // Examine the text in the response
                  response.json().then(function(data) {
                    img = new Image()
                    
                    img.onload = function() {
                      document.getElementById('title').innerText = data.title;
                      document.getElementsByTagName('title')[0].innerText = data.title;
                      document.getElementById('ts').innerText = data.taken_at;
                      document.getElementById('photo').style.backgroundImage = "url(\\"" + data.photo + "\\")";
                    }
                    img.src = data.photo;
                  });
                })
                .catch(function(err) {
                  console.log('Fetch Error :-S', err);
                });
              }
              var intervalID = window.setInterval(refreshImage, ${interval} * 1000);
              refreshImage();

              var noSleep = new NoSleep();
              document.addEventListener('click', function enableNoSleepAndFullScreen() {
                //document.removeEventListener('click', enableNoSleep, false);
                noSleep.enable();
                function requestFullScreen(element) {
                  var requestMethod = element.requestFullScreen || element.webkitRequestFullScreen || element.mozRequestFullScreen || element.msRequestFullScreen;                
                  requestMethod.call(element);                
                }
                requestFullScreen(document.body);
              }, false);
            """))
            
          )
        )
      ),
      headers = Seq("Content-Type" -> "text/html; charset=UTF-8")
    )
  }

  

  @cask.get(s"$basePath/photo/random/:categories")
  def randomPhoto(categories: String) = {
    
    // Ugly hack for IN condition
    val categoriesList = categories.split(",").map(_.trim).filter(_.nonEmpty).toList
    val input = (0 to 6).map(i => categoriesList.lift(i).getOrElse("TO_BE_IGNORED"))   
    
    ds.run:
      val photo = (sql"""
          select p.photo_uid as uid, p.photo_title as title, p.photo_type, f.file_hash, p.taken_at
          from files f
          INNER JOIN photos p ON p.photo_uid = f.photo_uid
          INNER JOIN photos_albums pa ON pa.photo_uid = p.photo_uid
          INNER JOIN albums a ON a.album_uid = pa.album_uid
          WHERE a.album_type = 'album' 
          AND a.album_category IN (${input(0)}, ${input(1)}, ${input(2)}, ${input(3)}, ${input(4)}, ${input(5)}, ${input(6)}) 
          AND p.photo_type = 'image'        
          ORDER BY RAND() LIMIT 1""".read[Photo]).headOption.getOrElse(Photo("INVALID_PHOTO","INVALID PHOTO","","",""))
      cask.Response(
        s"""
        {
          "photo": "${photoprismUrl}/api/v1/t/${photo.fileHash}/slideshow/fit_1920/",
          "title": "${photo.title}",
          "taken_at": "${photo.takenAt}"
        }
        """,
        headers = Seq("Content-Type" -> "application/json")
      )    
  }

  @cask.get(s"$basePath/random/:categories")
  def random(categories: String) = {
    
    // Ugly hack for IN condition
    val categoriesList = categories.split(",").map(_.trim).filter(_.nonEmpty).toList
    val input = (0 to 6).map(i => categoriesList.lift(i).getOrElse("TO_BE_IGNORED"))   
     
    ds.run:
      val photo = (sql"""
          select p.photo_uid as uid, p.photo_title as title, p.photo_type, f.file_hash, p.taken_at
          from files f
          INNER JOIN photos p ON p.photo_uid = f.photo_uid
          INNER JOIN photos_albums pa ON pa.photo_uid = p.photo_uid
          INNER JOIN albums a ON a.album_uid = pa.album_uid
          WHERE a.album_type = 'album' 
          AND a.album_category IN (${input(0)}, ${input(1)}, ${input(2)}, ${input(3)}, ${input(4)}, ${input(5)}, ${input(6)}) 
          AND p.photo_type = 'image'        
          ORDER BY RAND() LIMIT 1""".read[Photo]).headOption.getOrElse(Photo("INVALID_PHOTO","INVALID PHOTO","","",""))
      cask.Response(
        doctype("html")(
          html(
            head(
              tag("title")(s"${photo.title} - Photoprism Slideshow"),
              tag("style")(raw(s"""
                body {
                  margin: 0;
                  padding: 0;
                  background: url("${photoprismUrl}/api/v1/t/${photo.fileHash}/slideshow/fit_1920/") no-repeat top center fixed grey;
                  background-size: contain;
                }           
                #title {
                  position: absolute;
                  bottom: 0;
                  left: 0;
                  right: 0;
                  color: white;
                  padding: 1em;
                  font-family: sans-serif;
                }   
                """)),
              meta(name:="viewport", content:="width=device-width, initial-scale=1"),
              meta(name:="redirect", content:=s"${interval}; url=${basePath}/random/${categories}", httpEquiv:="refresh"),
            ),
            body(
              div(id:="title")(
                h1(photo.title),
                p(photo.takenAt)
              )
            )
          )
        ),
        headers = Seq("Content-Type" -> "text/html; charset=UTF-8")
      )
  }

  override def debugMode = true

  override def host = "0.0.0.0"

  override def port = scala.util.Properties.envOrElse("SERVER_PORT", "8080").toInt

  override def log = cask.util.Logger.Console()

  initialize()

}
