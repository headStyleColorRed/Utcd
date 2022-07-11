mod upload;

use actix_web::{App, HttpServer};
use std::io;
use actix_cors::Cors;
use crate::upload::download_query::download;
use crate::upload::upload_query::upload;
use crate::upload::delete_query::delete;
use crate::upload::files_query::files;

#[actix_rt::main]
async fn main() -> io::Result<()> {
    println!("Server started on port 8080");
    HttpServer::new(move || {
        let cors = Cors::permissive();
        App::new()
            .wrap(cors)
            .route("/upload", actix_web::web::post().to(upload))
            .service(download)
            .service(delete)
            .service(files)

    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
