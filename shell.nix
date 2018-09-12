# let
# in
# 	with nixpkgs;
# 	let
# 		nightlyBuildRustPlatform = recurseIntoAttrs 
# 				(makeRustPlatform 
# 					(
# 						{
# 							rustc = nixpkgs.latest.rustChannels.nightly.rust;
# 								# {
# 								# 	date = "2018-09-08";
# 								# 	hash = "1p0xkpfk66jq0iladqfrhqk1zc1jr9n2v2lqyf7jjbrmqx2ja65i";
# 								# }; 
# 							cargo = nixpkgs.latest.rustChannels.nightly.cargo;
# 						}
# 					)
# 				);

# 		racer = nightlyBuildRustPlatform.buildRustPackage rec {
# 			name = "racer-${version}";
# 			version = "v2.1.5";

# 			src = fetchFromGitHub {
# 				owner = "racer-rust";
# 				repo = "racer";
# 				rev = "${version}";
# 				sha256 = "0dn4qck8yxkafpd4lx06x5vg23q3ssi47n4b3778p15g27m6gkdl";
# 			};

# 			doCheck = false;

# 			cargoSha256 = "1qsjs3wq61njczqwcvj1gy3m55cmb37k4jgvpk2j5w64nba7mdx9";

# 			meta = with stdenv.lib; {
# 				description = "Rust Auto-Complete-er. A utility intended to provide Rust code completion for editors and IDEs.";
# 				homepage = https://github.com/racer-rust/racer;
# 				license = licenses.unlicense;
# 				maintainers = [ maintainers.tailhook ];
# 				platforms = platforms.all;
# 			};
# 		};
let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
in
  with nixpkgs;
  stdenv.mkDerivation {
    name = "rust-env";
    buildInputs = [
      (nixpkgs.rustChannelOf { date = "2018-09-09"; channel = "nightly"; }).rust
      (nixpkgs.rustChannelOf { date = "2018-09-07"; channel = "nightly"; }).cargo

      rustfmt ctags rustracer rustPlatform.rustcSrc carnix 
    ];

    # Set Environment Variables
    RUST_BACKTRACE = 1;
  }
