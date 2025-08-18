module crowdfund::sbt {
    use std::error;
    use std::signer;
    use aptos_framework::object::{Self, Object};

    const E_ALREADY_HAS_SBT: u64 = 0;
    const E_NOT_OWNER: u64 = 1;

    struct SBT has key {
        reputation: u64,
        owner: address,
        collection_name: vector<u8>,
        name: vector<u8>,
        uri: vector<u8>,
    }

    public entry fun mint_sbt(account: &signer, collection_name: vector<u8>, name: vector<u8>, uri: vector<u8>, soul_bound_to: address) {
        let addr = signer::address_of(account);
        // Check if user already has SBT
        assert!(!has_sbt(addr), error::already_exists(E_ALREADY_HAS_SBT));

        // Create a simple SBT resource instead of using token framework
        move_to(account, SBT {
            reputation: 0,
            owner: soul_bound_to,
            collection_name,
            name,
            uri,
        });
    }

    public fun has_sbt(addr: address): bool {
        // Check if SBT resource exists at the address
        exists<SBT>(addr)
    }

    public fun get_sbt_object(addr: address): Object<SBT> {
        // Create an object reference to the SBT resource
        object::address_to_object<SBT>(addr)
    }

    public fun get_reputation(addr: address): u64 acquires SBT {
        borrow_global<SBT>(addr).reputation
    }

    public fun update_reputation(addr: address, delta: u64) acquires SBT {
        let sbt = borrow_global_mut<SBT>(addr);
        sbt.reputation = sbt.reputation + delta;
    }

    // Public function for other modules to update reputation
    public fun update_reputation_by_delta(addr: address, delta: u64, add: bool) acquires SBT {
        let sbt = borrow_global_mut<SBT>(addr);
        if (add) {
            sbt.reputation = sbt.reputation + delta;
        } else {
            sbt.reputation = sbt.reputation - delta;
        };
    }
}