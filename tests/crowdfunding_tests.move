// module crowdfund::crowdfunding_tests {
//     use std::signer;
//     use aptos_framework::aptos_coin::{Self, AptosCoin};
//     use aptos_framework::coin;
//     use aptos_framework::account;
//     use crowdfund::sbt;
//     use crowdfund::campaign;
//     use crowdfund::zk_donation;

//     // Test setup function to initialize accounts and coins
//     fun setup_test(creator: &signer, donor1: &signer, donor2: &signer, aptos: &signer) {
//         // Initialize accounts with coins
//         let creator_addr = signer::address_of(creator);
//         let donor1_addr = signer::address_of(donor1);
//         let donor2_addr = signer::address_of(donor2);

//         account::create_account_for_test(creator_addr);
//         account::create_account_for_test(donor1_addr);
//         account::create_account_for_test(donor2_addr);

//         // Initialize APT first, then register
//         let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos);
//         coin::register<AptosCoin>(creator);
//         coin::register<AptosCoin>(donor1);
//         coin::register<AptosCoin>(donor2);
//         aptos_coin::mint(aptos, creator_addr, 10000);
//         aptos_coin::mint(aptos, donor1_addr, 5000);
//         aptos_coin::mint(aptos, donor2_addr, 5000);
//         coin::destroy_mint_cap(mint_cap);
//         coin::destroy_burn_cap(burn_cap);
//     }

//     #[test(creator = @0x123, donor1 = @0x456, donor2 = @0x789, aptos = @aptos_framework)]
//     fun test_full_flow(creator: &signer, donor1: &signer, donor2: &signer, aptos: &signer) {
//         setup_test(creator, donor1, donor2, aptos);
//         let creator_addr = signer::address_of(creator);
//         let donor1_addr = signer::address_of(donor1);
//         let _donor2_addr = signer::address_of(donor2);

//         // Test 1: Mint SBT for creator and donor
//         sbt::mint_sbt(
//             creator,
//             b"Crowdfund Collection",
//             b"Creator SBT",
//             b"https://example.com/sbt/creator",
//             creator_addr
//         );
//         sbt::mint_sbt(
//             donor1,
//             b"Crowdfund Collection",
//             b"Donor1 SBT",
//             b"https://example.com/sbt/donor1",
//             donor1_addr
//         );
//         sbt::mint_sbt(
//             donor2,
//             b"Crowdfund Collection",
//             b"Donor2 SBT",
//             b"https://example.com/sbt/donor2",
//             _donor2_addr
//         );
//         assert!(sbt::has_sbt(creator_addr), 1);
//         assert!(sbt::has_sbt(donor1_addr), 2);
//         assert!(sbt::has_sbt(_donor2_addr), 3);

//         // Test 2: Create a campaign
//         let milestone_descs = vector[
//             b"Complete Semester 1",
//             b"Complete Semester 2",
//         ];
//         let milestone_amounts = vector[250, 250];
//         campaign::create_campaign(creator, 500, milestone_descs, milestone_amounts);

//         // Test 3: Donors donate to campaign (campaign is stored under creator's address)
//         campaign::donate(donor1, creator_addr, 300);
//         campaign::donate(donor2, creator_addr, 200);
//         assert!(campaign::get_raised(creator_addr) == 500, 3);

//         // Test 4: Check reputation update for donors
//         // Reputation check requires a getter; skip direct field access

//         // Test 5: Claim and vote on milestone
//         campaign::claim_milestone(creator, creator_addr, 0);
//         // Note: Voting functionality is currently placeholder, so we'll skip voting tests

//         // Test 6: Release funds for approved milestone
//         // Note: Milestone needs to be approved first, so we'll skip this for now
//         // campaign::release_funds(creator_addr, 0);

//         // Test 7: Check reputation update for creator
//         // Reputation check requires a getter; skip direct field access
//     }

//     #[test(creator = @0x123, donor = @0x456, aptos = @aptos_framework)]
//     #[expected_failure(abort_code = 524288, location = crowdfund::sbt)]
//     fun test_sbt_already_exists(creator: &signer, donor: &signer, aptos: &signer) {
//         setup_test(creator, donor, donor, aptos);
//         let creator_addr = signer::address_of(creator);
//         sbt::mint_sbt(
//             creator,
//             b"Crowdfund Collection",
//             b"Creator SBT",
//             b"https://example.com/sbt/creator",
//             creator_addr
//         );
//         // Should fail: minting SBT again for the same address
//         sbt::mint_sbt(
//             creator,
//             b"Crowdfund Collection",
//             b"Creator SBT 2",
//             b"https://example.com/sbt/creator2",
//             creator_addr
//         );
//     }

//     #[test(creator = @0x123, donor = @0x456, aptos = @aptos_framework)]
//     fun test_zk_donation(creator: &signer, donor: &signer, aptos: &signer) {
//         setup_test(creator, donor, donor, aptos);
//         let creator_addr = signer::address_of(creator);
//         let _donor_addr = signer::address_of(donor);

//         // Mint SBT for creator
//         sbt::mint_sbt(
//             creator,
//             b"Crowdfund Collection",
//             b"Creator SBT",
//             b"https://example.com/sbt/creator",
//             creator_addr
//         );

//         // Create a campaign
//         let milestone_descs = vector[b"Complete Semester 1"];
//         let milestone_amounts = vector[250];
//         campaign::create_campaign(creator, 500, milestone_descs, milestone_amounts);

//         // Mock ZK proof parameters (using basic types)
//         let proof_a = vector[0u8, 1u8, 2u8]; // Mock proof component A
//         let proof_b = vector[3u8, 4u8, 5u8]; // Mock proof component B
//         let proof_c = vector[6u8, 7u8, 8u8]; // Mock proof component C
//         let public_inputs = vector[300u64]; // Mock amount
//         let vk_alpha = vector[9u8, 10u8, 11u8]; // Mock verifying key alpha
//         let vk_beta = vector[12u8, 13u8, 14u8]; // Mock verifying key beta
//         let vk_gamma = vector[15u8, 16u8, 17u8]; // Mock verifying key gamma
//         let vk_delta = vector[18u8, 19u8, 20u8]; // Mock verifying key delta

//         // Perform private donation
//         zk_donation::private_donate(donor, creator_addr, proof_a, proof_b, proof_c, public_inputs, vk_alpha, vk_beta, vk_gamma, vk_delta);
//         assert!(campaign::get_raised(creator_addr) == 300, 10);
//     }
    
// }
module crowdfund::crowdfunding_tests {
    use std::signer;
    use aptos_framework::aptos_coin::{Self, AptosCoin};
    use aptos_framework::coin;
    use aptos_framework::account;
    use crowdfund::sbt;
    use crowdfund::campaign;
    use crowdfund::zk_donation;

    // Test setup function to initialize accounts and coins
    fun setup_test(creator: &signer, donor1: &signer, donor2: &signer, aptos: &signer) {
        // Initialize accounts with coins
        let creator_addr = signer::address_of(creator);
        let donor1_addr = signer::address_of(donor1);
        let donor2_addr = signer::address_of(donor2);

        account::create_account_for_test(creator_addr);
        account::create_account_for_test(donor1_addr);
        account::create_account_for_test(donor2_addr);

        // Initialize APT first, then register
        let (burn_cap, mint_cap) = aptos_coin::initialize_for_test(aptos);
        coin::register<AptosCoin>(creator);
        coin::register<AptosCoin>(donor1);
        coin::register<AptosCoin>(donor2);
        aptos_coin::mint(aptos, creator_addr, 10000);
        aptos_coin::mint(aptos, donor1_addr, 5000);
        aptos_coin::mint(aptos, donor2_addr, 5000);
        coin::destroy_mint_cap(mint_cap);
        coin::destroy_burn_cap(burn_cap);
    }

    #[test(creator = @0x123, donor1 = @0x456, donor2 = @0x789, aptos = @aptos_framework)]
    fun test_full_flow(creator: &signer, donor1: &signer, donor2: &signer, aptos: &signer) {
        setup_test(creator, donor1, donor2, aptos);
        let creator_addr = signer::address_of(creator);
        let donor1_addr = signer::address_of(donor1);
        let donor2_addr = signer::address_of(donor2);

        // Test 1: Mint SBT for creator and donors
        sbt::mint_sbt(
            creator,
            b"Crowdfund Collection",
            b"Creator SBT",
            b"https://example.com/sbt/creator"
        );
        sbt::mint_sbt(
            donor1,
            b"Crowdfund Collection",
            b"Donor1 SBT",
            b"https://example.com/sbt/donor1"
        );
        sbt::mint_sbt(
            donor2,
            b"Crowdfund Collection",
            b"Donor2 SBT",
            b"https://example.com/sbt/donor2"
        );
        assert!(sbt::has_sbt(creator_addr), 1);
        assert!(sbt::has_sbt(donor1_addr), 2);
        assert!(sbt::has_sbt(donor2_addr), 3);

        // Test 2: Create a campaign
        let milestone_descs = vector[
            b"Complete Semester 1",
            b"Complete Semester 2",
        ];
        let milestone_amounts = vector[250, 250];
        campaign::create_campaign(creator, 500, milestone_descs, milestone_amounts);

        // Test 3: Donors donate to campaign
        campaign::donate(donor1, creator_addr, 300);
        campaign::donate(donor2, creator_addr, 200);
        assert!(campaign::get_raised(creator_addr) == 500, 3);

        // Test 4: Check reputation update for donors (getter required)

        // Test 5: Claim and vote on milestone
        campaign::claim_milestone(creator, creator_addr, 0);

        // Test 6: Release funds for approved milestone (skipped)

        // Test 7: Check reputation update for creator (getter required)
    }

    #[test(creator = @0x123, donor = @0x456, aptos = @aptos_framework)]
    #[expected_failure(abort_code = 524288, location = crowdfund::sbt)]
    fun test_sbt_already_exists(creator: &signer, donor: &signer, aptos: &signer) {
        setup_test(creator, donor, donor, aptos);
        let creator_addr = signer::address_of(creator);

        sbt::mint_sbt(
            creator,
            b"Crowdfund Collection",
            b"Creator SBT",
            b"https://example.com/sbt/creator"
        );
        // Should fail: minting SBT again for the same address
        sbt::mint_sbt(
            creator,
            b"Crowdfund Collection",
            b"Creator SBT 2",
            b"https://example.com/sbt/creator2"
        );
    }

    #[test(creator = @0x123, donor = @0x456, aptos = @aptos_framework)]
    fun test_zk_donation(creator: &signer, donor: &signer, aptos: &signer) {
        setup_test(creator, donor, donor, aptos);
        let creator_addr = signer::address_of(creator);
        let donor_addr = signer::address_of(donor);

        // Mint SBT for creator
        sbt::mint_sbt(
            creator,
            b"Crowdfund Collection",
            b"Creator SBT",
            b"https://example.com/sbt/creator"
        );

        // Create a campaign
        let milestone_descs = vector[b"Complete Semester 1"];
        let milestone_amounts = vector[250];
        campaign::create_campaign(creator, 500, milestone_descs, milestone_amounts);

        // Mock ZK proof parameters
        let proof_a = vector[0u8, 1u8, 2u8];
        let proof_b = vector[3u8, 4u8, 5u8];
        let proof_c = vector[6u8, 7u8, 8u8];
        let public_inputs = vector[300u64];
        let vk_alpha = vector[9u8, 10u8, 11u8];
        let vk_beta = vector[12u8, 13u8, 14u8];
        let vk_gamma = vector[15u8, 16u8, 17u8];
        let vk_delta = vector[18u8, 19u8, 20u8];

        // Perform private donation
        zk_donation::private_donate(
            donor, creator_addr, proof_a, proof_b, proof_c,
            public_inputs, vk_alpha, vk_beta, vk_gamma, vk_delta
        );
        assert!(campaign::get_raised(creator_addr) == 300, 10);
    }
}
