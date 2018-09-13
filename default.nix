let
  moz_overlay = import ((import <nixpkgs> {}).fetchFromGitHub 
    { owner = "mozilla";
      repo = "nixpkgs-mozilla";
      inherit 
       ({ url = "https://github.com/mozilla/nixpkgs-mozilla";
          rev = "136eacc0ceefa8fb44677799e5639e083606ee5d";
          sha256 = "04bz093x3zjkzp7ba8mh876a1a34kp3jrys87m79gbln5qvcd2ir";
          fetchSubmodules = false;
	}) rev sha256;
    });

  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
in
  ((import ./distributed_max.nix).distributed_max {}).override 
    { 
      rust = (nixpkgs.rustChannelOf { date = "2018-09-09"; channel = "nightly"; }).rust;
    }

