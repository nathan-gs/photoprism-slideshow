package photoprism.slideshow

import simplesql as sq
import photoprism.slideshow.domain._

val ds: javax.sql.DataSource = {
    val ds = org.sqlite.SQLiteDataSource()
    ds.setUrl("jdbc:sqlite:./index.db")
    ds
}


@main def main = {
    sq.transaction(ds){
        
        //println(sq.read[Album](sql"SELECT $fields"))
        val albums = sq.read[Album](sql"""
            select album_uid, album_title, album_type, album_category 
            from albums 
            WHERE 
            album_type = 'album' AND album_category = 'Travel' 
            ORDER BY album_title ASC""")

        albums.foreach(a => {
            println("-----------------------------")
            println(a)
            sq.read[Photo](sql"""
                select p.photo_uid, p.photo_title, p.photo_type, f.file_hash
                from files f
                INNER JOIN photos p ON p.photo_uid = f.photo_uid
                INNER JOIN photos_albums pa ON pa.photo_uid = p.photo_uid
                WHERE pa.album_uid = ${a.uid} AND p.photo_type = 'image'                
                LIMIT 5""")
                .foreach(p => println(p))
        })
        
    }
}