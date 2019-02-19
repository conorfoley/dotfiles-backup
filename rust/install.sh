# install rust
curl https://sh.rustup.rs -sSf | sh
rustup install nightly
rustup default nightly

# install racer
rustup toolchain add nightly
rustup component add rust-src
cargo +nightly install racer

cargo install rustfmt
