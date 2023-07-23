package photoprism.slideshow.domain

import simplesql as sq

case class Album(uid: String, title: String, albumType: String, category: String) derives sq.Reader

case class Photo(uid: String, title: String, photoType: String, fileHash: String) derives sq.Reader