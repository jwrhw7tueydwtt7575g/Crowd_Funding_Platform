module crowdfund::voting {
    use std::error;
    use std::signer;
    use std::simple_map::{Self, SimpleMap};
    use crowdfund::campaign;

    const E_NOT_DONOR: u64 = 200;
    const E_ALREADY_VOTED: u64 = 201;
    const E_VOTE_NOT_ENDED: u64 = 202;

    struct Vote has key {
        campaign_addr: address,
        milestone_index: u64,
        yes_votes: u64,
        no_votes: u64,
        voters: SimpleMap<address, bool>,
    }

    public fun start_vote(_campaign_addr: address, _milestone_index: u64) {
        // Placeholder for future implementation
    }

    public entry fun vote(account: &signer, vote_addr: address, yes: bool) acquires Vote {
        let voter = signer::address_of(account);
        let vote = borrow_global_mut<Vote>(vote_addr);
        assert!(campaign::is_donor(vote.campaign_addr, voter), error::permission_denied(E_NOT_DONOR));
        assert!(!simple_map::contains_key(&vote.voters, &voter), error::already_exists(E_ALREADY_VOTED));
        if (yes) {
            vote.yes_votes = vote.yes_votes + 1;
        } else {
            vote.no_votes = vote.no_votes + 1;
        };
        simple_map::add(&mut vote.voters, voter, yes);
    }

    public entry fun end_vote(vote_addr: address) acquires Vote {
        let vote = borrow_global_mut<Vote>(vote_addr);
        if (vote.yes_votes > vote.no_votes) {
            campaign::set_milestone_approved(vote.campaign_addr, vote.milestone_index, true);
        };
        campaign::set_milestone_voting_in_progress(vote.campaign_addr, vote.milestone_index, false);
        // Clean up vote resource if needed
    }
}