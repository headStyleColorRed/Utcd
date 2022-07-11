use actix_web::{delete, Responder};
use actix_web::{HttpRequest};

#[delete("/files/{folder}/{file}")]
async fn delete(req: HttpRequest) -> impl Responder {
    // Get file path
    let folder: String = req.match_info().query("folder").parse().unwrap();
    let file: String = req.match_info().query("file").parse().unwrap();
    let path: String = format!("src/upload/files/{:?}/{:?}", folder, file).replace("\"", "");

    // Delete file
    match std::fs::remove_file(path) {
        Ok(_) => "File deleted".to_string(),
        Err(_) => "Error deleting file".to_string()
    }
}
