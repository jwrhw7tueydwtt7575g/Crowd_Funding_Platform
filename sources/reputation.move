module crowdfund::reputation {
    use crowdfund::sbt::{Self};

    public entry fun update_reputation(_account: &signer, user: address, delta: u64, add: bool) {
        // Use the public function from sbt module instead of direct field access
        sbt::update_reputation_by_delta(user, delta, add);
    }
}