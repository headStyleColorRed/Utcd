use actix_web::{get};
use actix_web::{HttpRequest};
use glob::glob;

#[get("/files/{locale}")]
async fn files(req: HttpRequest) ->  Result<actix_web::HttpResponse, actix_web::Error> {
    // Get file path
    let locale: String = req.match_info().query("locale").parse().unwrap();

    // Delete file
    let mut paths: Vec<String> = vec![];

    for file in glob(&format!("./src/upload/files/{}/*", locale)).expect("Failed to read glob pattern") {
        if let Ok(path) = file {
            if let Some(path) = path.to_str() {
                let file_name = path.split("/").last().unwrap();
                paths.push(file_name.to_string());
            }
        }
    }

    Ok(actix_web::HttpResponse::Ok().json(paths))
}
