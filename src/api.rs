use serde_derive::{Deserialize, Serialize};

pub mod v1 {
    use super::*;
    use chrono::{DateTime, Utc};

    #[derive(Deserialize)]
    pub struct CreateRequest {
        pub url: String,
        pub exp: Option<DateTime<Utc>>,
    }

    #[derive(Serialize)]
    pub struct CreateResponse {
        pub url: String,
        pub id: String,
        pub short_url: String,
        pub expires: Option<DateTime<Utc>>,
    }
}
