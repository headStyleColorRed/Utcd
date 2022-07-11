use std::path::PathBuf;
use serde::{Deserialize, Serialize};
use actix_web::web::Query;
use std::fs;

#[derive(Debug, Deserialize)]
pub struct Params {
    folder: String,
}
impl Default for Params {
    fn default() -> Self {
        Params {
            folder: "".to_string(),
        }
    }
}

#[derive(Debug, Serialize)]
struct NewFile {
    path: String
}

// Example => http://localhost:8080/upload?folder=rodrigo
pub async fn upload(mut parts: awmp::Parts, Query(info): Query<Params>) -> Result<actix_web::HttpResponse, actix_web::Error> {
    // Get query file folder
    let mut folder = info.folder;

    // Give folder a default value if it is empty
    if folder.is_empty() {
        folder = uuid::Uuid::new_v4().to_string();
    }

    // Set directory path
    let directory_buffer: PathBuf = match std::env::current_dir() {
        Ok(dir) => dir,
        Err(e) => return Err(e.into()),
    };
    let root_directory = directory_buffer.as_path().display().to_string();
    let files_directory = "/src/upload/files/".to_string();
    let full_path = format!("{}{}{}", root_directory, files_directory, folder);

    // Create directory if it doesn't exist
    if !fs::metadata(&full_path).is_ok() {
        fs::create_dir_all(&full_path).expect("Unable to create directory");
    }

    // Save file into created directory
    let new_file = parts
        .files
        .take("file")
        .pop()
        .and_then(|f| f.persist_in(full_path).ok())
        .map(|f| f.display().to_string());


    // Get file name
    let final_file_path: String = match new_file.clone() {
        Some(file) => file.split("/").last().unwrap().to_string(),
        None =>  return Err(actix_web::error::ErrorBadRequest("No 'file' found in request".to_string())),
    };

    let mut full_image_path: String = folder.clone();
    full_image_path.push_str("/");
    full_image_path.push_str(&final_file_path);

    match new_file {
        Some(_) => Ok(actix_web::HttpResponse::Ok().json(full_image_path)),
        None => Ok(actix_web::HttpResponse::Ok().json("\"file\": \"Error saving file\"")),
    }
}
