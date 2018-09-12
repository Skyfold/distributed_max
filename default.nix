let
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> { overlays = [ moz_overlay ]; };
in
  ((import ./distributed_max.nix).distributed_max {}).override 
    { 
      rust = (nixpkgs.rustChannelOf { date = "2018-09-09"; channel = "nightly"; }).rust;
    }

