## Introduction

This is the code for a coding challenge about reaching consensus in a distributed environment.

## Challenge Question

Q1. In the programming language of your choice, implement a distributed algorithm for finding the maximum number between nodes.

- Nodes generate a random 64-bit number at start up, and must form a consensus about the maximum number across all nodes.
- Each node should be modeled as a thread (so pick a programming language that has threads).
- Nodes can only communicate with each other using message passing (so pick a programming language with channels, or model message passing using FIFO queues).
- Nodes can only communicate with 1/10th of the other nodes (you can decide how to configure them).
- Nodes should print out the maximum number when they have it. Each node can only print once. Not all nodes need to print the correct number, but the more, the better.
- The program should be a command-line tool, that accepts the number of nodes as an argument.

Focus on an implementation that achieves consensus consistently. Remember to check all concurrent data access for data-races.

## How to Build

The code can be built either reproducibly with Nix which guarantees you end up with the same executable as I did or with cargo, the default Rust build tool. Since the code has only one external Rust dependency it should build with cargo easily as long as you are on a Rust Nightly version of `rustc`:

```
rustc 1.30.0-nightly (0198a1ea4 2018-09-08)
cargo 1.29.0-nightly (0ec7281b9 2018-08-20)
```

The downside of using Nix is the fact that reproducibility requires that many of the dependencies are built from scratch (if nixos.org has not cached them). `nix-build` will bootstrap the rustc complier from the highest stable version it can find on the cache. Be prepared to wait up to or more than 20min (depending on how many of the dependencies Nix can find pre-built). Subsequent builds are fast.

Note: This problem can be solved by either using cachix or running your own Hydra instance. This applies for both building the executable and getting the development environment up and running fast.

### Nix

If you don't have nix: [link to install nix](https://nixos.org/nix/download.html). After nix is installed you just need to run the command below wherever you cloned this repository.

```
nix-build
```

The binary will be linked in to `./result/bin/distributed_max`

### Cargo

```
cargo build
```

## How to run the code

```
distributed_max <num> [time in milliseconds]
```

Examples:

```
distributed_max 5
```

Will create 5 nodes in a circuit (can talk to both neighbors).

```
distributed_max 500 50000
```

Will create 500 nodes in a circuit and give them 50000 milliseconds to find the max number.

Notes:
  - I currently use a hack to "guess" how long to give the nodes (<num> * 10) milliseconds.
  - The nodes do not know how many nodes there, only how to talk to their neighbors and receive messages
  - If the nodes start to fail to give the same number (after about 100 given the low wait time) then just give them more time

## Development Environment

The build environment brings in useful development tools such as:
  - rustfmt
  - racer
  - ctags
  - rustcSrc (nix equivalent to rust-src)

To get the development environment you just need to run the below command wherever you cloned this repository:

```
nix-shell
```

Note: This will put you in bash and will require you to run everything that needs access to either the above tools or `cargo` and `rustc` in that shell. There are other ways to get the environment from nix-shell without dropping you in another shell like `direnv`.


## Codes Notes

I currently create one actual OS thread per node, which is partly why you need to wait awhile as the number of nodes increases. On top of that I made the default a two way circuit which is a very inefficient way to connect 500+ nodes. The code easily supports other topologies, but that seemed to be beyond what the question was asking for.
