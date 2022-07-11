use actix_web::{get};
use actix_files::NamedFile;
use actix_web::{HttpRequest, Result};

#[get("/files/{locale}/{file}")]
async fn download(req: HttpRequest) -> Result<NamedFile> {
    let locale: String = req.match_info().query("locale").parse().unwrap();
    let file: String = req.match_info().query("file").parse().unwrap();

    let path: String = format!("src/upload/files/{:?}/{:?}", locale, file).replace("\"", "");

    // Check for malicious path
    if path.contains("..") {
        return Err(actix_web::error::ErrorInternalServerError("File not found".to_string()));
    }

    Ok(NamedFile::open(path)?)
}
