mod api;

use api::v1::{CreateRequest, CreateResponse};

use std::error::Error;

use lambda_runtime::{error::HandlerError, lambda, Context};
use log::{error, info};
use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};
use simple_error::bail;
use simple_logger;
use url::Url;

fn create_short(r: CreateRequest, c: Context) -> Result<CreateResponse, HandlerError> {
    if r.url.is_empty() {
        error!("empty url in request {}", c.aws_request_id);
        bail!("empty url")
    }

    let parsed_url = match Url::parse(&r.url) {
        Ok(parsed_url) => parsed_url,
        Err(e) => {
            error!(
                "{}: failed to parse url for request {}",
                e.to_string(),
                c.aws_request_id
            );
            return Err("invalid url".into());
        }
    };

    if let Some(exp) = r.exp {
        info!("request {} has expiry value {}", c.aws_request_id, exp);
        let now = chrono::offset::Utc::now();
        if exp <= now + chrono::Duration::minutes(1) {
            error!(
                "expiry must be at least 1 minute in the future {}",
                c.aws_request_id
            );
            bail!("expiry in past")
        }
    }

    let rand_string: String = thread_rng().sample_iter(&Alphanumeric).take(10).collect();
    Ok(CreateResponse {
        url: parsed_url.to_string(),
        short_url: format!("https://eatmy.rs/{}", rand_string),
        id: rand_string,
        expires: r.exp,
    })
}

fn main() -> Result<(), Box<dyn Error>> {
    simple_logger::init_with_level(log::Level::Debug)?;
    lambda!(create_short);

    Ok(())
}
