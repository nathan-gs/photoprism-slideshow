package photoprism.slideshow.domain

import simplesql as sq

case class Photo(uid: String, title: String, photoType: String, fileHash: String, takenAt: String) derives sq.Reader

object Photo {
  
  implicit def photoRW: upickle.default.ReadWriter[Photo] = upickle.default.macroRW[Photo]

}