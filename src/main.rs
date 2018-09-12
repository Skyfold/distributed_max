extern crate rand;

use rand::Rng;
use std::cmp::max;
use std::collections::BTreeMap;
use std::collections::HashSet;
use std::env;
use std::process::exit;
use std::sync::mpsc::*;
use std::thread;
use std::time::{Duration, Instant};

fn gen_threads(
    topology: impl Iterator<Item = (u64, u64)>,
    time: Duration,
) -> Vec<thread::JoinHandle<()>> {
    let mut senders: BTreeMap<u64, Vec<Sender<u64>>> = BTreeMap::new();
    let mut receivers: BTreeMap<u64, Vec<Receiver<u64>>> = BTreeMap::new();
    let mut duplicats: HashSet<u64> = HashSet::new();

    topology
        .into_iter()
        .map(|(from, to)| {
            let (send, rec) = channel();
            senders.entry(from).or_insert(Vec::new()).push(send);
            receivers.entry(to).or_insert(Vec::new()).push(rec);
        }).last();

    let nodes: Vec<u64> = senders
        .keys()
        .chain(receivers.keys())
        .filter(|x| duplicats.insert(**x))
        .cloned()
        .collect();

    nodes
        .into_iter()
        .map(|x| {
            (
                senders.remove(&x).unwrap_or(vec![]),
                receivers.remove(&x).unwrap_or(vec![]),
            )
        }).map(|(send_to, receive)| {
            thread::spawn(move || {
                let mut secret_number: u64 = rand::thread_rng().gen();
                let mut old_secret_number = secret_number + 1;
                let start_time = Instant::now();
                loop {
                    if old_secret_number != secret_number {
                        send_to.iter().map(|tx| tx.send(secret_number)).last();
                        old_secret_number = secret_number;
                    }

                    receive
                        .iter()
                        .map(|rx| {
                            rx.try_iter()
                                .map(|x| secret_number = max(secret_number, x))
                                .last();
                        }).last();

                    if start_time.elapsed() > time {
                        break;
                    }
                }
                println!("{}", secret_number);
            })
        }).collect()
}

fn ring(size: u64) -> impl Iterator<Item = (u64, u64)> {
    let t: Vec<(u64, u64)> = vec![(size, 1)];
    (1..(size + 1)).zip(2..(size + 1)).chain(t.into_iter())
}

fn cycle(size: u64) -> impl Iterator<Item = (u64, u64)> {
    let t: Vec<(u64, u64)> = vec![(1, size)];
    ring(size)
        .chain((1..(size + 1)).rev().zip((1..size).rev()))
        .chain(t.into_iter())
}

fn main() {
    let args: Vec<String> = env::args().collect();
    let size: u64 = match args.get(1).map(|x| x.trim().parse()) {
        Some(Ok(num)) => num,
        _ => {
            println!("requires the number of nodes as the first argument");
            exit(0)
        }
    };
    let time: u64 = match args.get(2).map(|x| x.trim().parse()) {
        Some(Ok(num)) => num,
        _ => size * 10,
    };

    let handles = gen_threads(cycle(size), Duration::from_millis(time));
    handles.into_iter().map(|x| x.join()).last();
}
