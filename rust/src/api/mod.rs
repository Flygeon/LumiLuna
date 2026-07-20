pub mod media_scan;
pub use media_scan::*;

pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
