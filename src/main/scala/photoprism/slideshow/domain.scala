package photoprism.slideshow.domain

import simplesql as sq

case class Album(uid: String, title: String, albumType: String, category: String) derives sq.Reader

object Album {
  
  implicit def albumRW: upickle.default.ReadWriter[Album] = upickle.default.macroRW[Album]

}

case class Photo(uid: String, title: String, photoType: String, fileHash: String) derives sq.Reader

object Photo {
  
  implicit def photoRW: upickle.default.ReadWriter[Photo] = upickle.default.macroRW[Photo]

}