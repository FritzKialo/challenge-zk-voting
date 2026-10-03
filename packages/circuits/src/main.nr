use std::hash::poseidon::bn254::hash_1;
use std::hash::poseidon::bn254::hash_2;
////// Checkpoint 4 //////
use binary_merkle_root::binary_merkle_root;

fn main(
    // public inputs
    nullifier_hash: pub Field,
    // private inputs
    nullifier: Field,
    secret: Field,
    ////// Checkpoint 4 //////
    // public inputs
    root: pub Field,
    vote: pub bool,
    depth: pub u32,
    // private inputs
    index: Field,
    siblings: [Field; 16],
) {
    ////// Checkpoint 3 //////
    // The public nullifier hash must be the hash of the private nullifier
    let computed_nullifier_hash = hash_1([nullifier]);
    assert(computed_nullifier_hash == nullifier_hash);

    // The commitment (the Merkle leaf) is the hash of nullifier and secret
    let commitment = hash_2([nullifier, secret]);

    ////// Checkpoint 4 //////
    // Count the non-zero siblings: this is the real length of the Merkle path
    let mut siblings_num: u32 = 0;
    for i in 0..16 {
        if siblings[i] != 0 {
            siblings_num += 1;
        }
    }

    // The claimed depth can't exceed the fixed array length
    assert(depth <= 16);

    // Index as 16 little-endian bits: each bit says whether the node is left (0) or right (1)
    let indices: [u1; 16] = index.to_le_bits();

    // Recompute the Merkle root from the leaf and its siblings
    let computed_root = binary_merkle_root(hash_2, commitment, siblings_num, indices, siblings);

    // The recomputed root must match the public on-chain root
    assert(computed_root == root);

    // Bind the vote to the proof: cast to Field and enforce x * x == x (so it is 0 or 1)
    let vote_field = vote as Field;
    assert(vote_field * vote_field == vote_field);
}