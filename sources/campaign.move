module crowdfund::campaign {
    use std::error;
    use std::signer;
    use std::vector;
    use std::simple_map::{Self, SimpleMap};
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use crowdfund::reputation;
    use crowdfund::sbt;

    const E_CAMPAIGN_NOT_FOUND: u64 = 100;
    const E_MILESTONE_NOT_MET: u64 = 101;
    const E_INSUFFICIENT_FUNDS: u64 = 102;
    const E_NOT_OWNER: u64 = 103;

    struct Milestone has store {
        description: vector<u8>,
        target_amount: u64,
        approved: bool,
        voting_in_progress: bool,
    }

    struct Campaign has key {
        creator: address,
        goal: u64,
        raised: u64,
        milestones: vector<Milestone>,
        donors: SimpleMap<address, u64>,
        escrow: coin::Coin<AptosCoin>,
    }

    public entry fun create_campaign(account: &signer, goal: u64, milestone_descriptions: vector<vector<u8>>, milestone_amounts: vector<u64>) {
        let addr = signer::address_of(account);
        sbt::has_sbt(addr); // Ensure has SBT

        let num_milestones = vector::length(&milestone_descriptions);
        let milestones = vector::empty<Milestone>();
        let i = 0;
        while (i < num_milestones) {
            vector::push_back(&mut milestones, Milestone {
                description: *vector::borrow(&milestone_descriptions, i),
                target_amount: *vector::borrow(&milestone_amounts, i),
                approved: false,
                voting_in_progress: false,
            });
            i = i + 1;
        };

        move_to(account, Campaign {
            creator: addr,
            goal: goal,
            raised: 0,
            milestones,
            donors: simple_map::create(),
            escrow: coin::zero<AptosCoin>(),
        });
    }

    public entry fun donate(account: &signer, campaign_addr: address, amount: u64) acquires Campaign {
        let donor = signer::address_of(account);
        let campaign = borrow_global_mut<Campaign>(campaign_addr);
        coin::transfer<AptosCoin>(account, campaign_addr, amount); // Transfer to escrow
        campaign.raised = campaign.raised + amount;
        if (simple_map::contains_key(&campaign.donors, &donor)) {
            let don = simple_map::borrow_mut(&mut campaign.donors, &donor);
            *don = *don + amount;
        } else {
            simple_map::add(&mut campaign.donors, donor, amount);
        };
        coin::merge(&mut campaign.escrow, coin::withdraw<AptosCoin>(account, amount));
        reputation::update_reputation(account, donor, 1, true); // Increase rep
    }

    public entry fun claim_milestone(account: &signer, campaign_addr: address, milestone_index: u64) acquires Campaign {
        let creator = signer::address_of(account);
        let campaign = borrow_global_mut<Campaign>(campaign_addr);
        assert!(creator == campaign.creator, error::permission_denied(E_NOT_OWNER));
        let milestone = vector::borrow_mut(&mut campaign.milestones, milestone_index);
        // Mark voting as in progress instead of directly calling voting module
        milestone.voting_in_progress = true;
    }

    public entry fun release_funds(campaign_addr: address, milestone_index: u64) acquires Campaign {
        let campaign = borrow_global_mut<Campaign>(campaign_addr);
        let milestone = vector::borrow(&campaign.milestones, milestone_index);
        assert!(milestone.approved, error::invalid_state(E_MILESTONE_NOT_MET));
        let amount = milestone.target_amount;
        assert!(coin::value(&campaign.escrow) >= amount, error::invalid_argument(E_INSUFFICIENT_FUNDS));
        let released = coin::extract(&mut campaign.escrow, amount);
        coin::deposit(campaign.creator, released);
        // Note: reputation update would need to be called by the creator themselves
        // reputation::update_reputation(&signer::create_signer(campaign.creator), campaign.creator, 5, true);
    }

    // Helper accessors
    public fun get_campaign_creator(campaign_addr: address): address acquires Campaign {
        borrow_global<Campaign>(campaign_addr).creator
    }

    public fun get_raised(campaign_addr: address): u64 acquires Campaign {
        borrow_global<Campaign>(campaign_addr).raised
    }

    // Query helpers for other modules (do not return references)
    public fun is_donor(campaign_addr: address, addr: address): bool acquires Campaign {
        simple_map::contains_key(&borrow_global<Campaign>(campaign_addr).donors, &addr)
    }

    // Public functions for other modules to update campaign data
    public fun update_campaign_raised(campaign_addr: address, amount: u64) acquires Campaign {
        let campaign = borrow_global_mut<Campaign>(campaign_addr);
        campaign.raised = campaign.raised + amount;
    }

    public fun set_milestone_approved(campaign_addr: address, milestone_index: u64, approved: bool) acquires Campaign {
        let milestone = vector::borrow_mut(&mut borrow_global_mut<Campaign>(campaign_addr).milestones, milestone_index);
        milestone.approved = approved;
    }

    public fun set_milestone_voting_in_progress(campaign_addr: address, milestone_index: u64, in_progress: bool) acquires Campaign {
        let milestone = vector::borrow_mut(&mut borrow_global_mut<Campaign>(campaign_addr).milestones, milestone_index);
        milestone.voting_in_progress = in_progress;
    }
}