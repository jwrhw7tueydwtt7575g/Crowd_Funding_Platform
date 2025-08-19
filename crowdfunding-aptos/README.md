🌟 Aptos Crowdfunding Platform 🌟
Welcome to the Aptos Crowdfunding Platform, a vibrant and feature-packed decentralized application (dApp) built on the Aptos Blockchain! 🚀 This platform empowers creators and donors with Soulbound NFTs (SBTs), milestone-based campaigns, and on-chain voting, all wrapped in a sleek and modern frontend. Let's bring your crowdfunding ideas to life with secure, transparent, and community-driven funding! 💸

✨ Features
🎨 Identity Setup: Mint Soulbound NFTs to establish a unique, non-transferable identity for users.💡 Campaign Creation: Set crowdfunding goals and define milestones to keep projects on track.💰 Donation & Escrow: Securely donate Octas (APT test coins) into escrow for safe fund management.🗳️ Milestone Voting: Donors vote to approve or reject milestone completions, ensuring accountability.🏆 Reputation System: Track creator and donor reputation on-chain to build trust.🌐 Frontend Integration: Seamlessly connect with Petra Wallet, sign transactions, and view real-time campaign data.

🛠️ Tech Stack
Backend / Smart Contracts

Aptos Blockchain: A permissionless, high-performance Layer 1 blockchain. ⚡
Move Language: Secure and modular smart contracts for identity, campaigns, escrow, and voting. 📜

Frontend

Next.js + Tailwind CSS: A modern React framework paired with utility-first CSS for a stunning UI. 🎨
Petra Wallet SDK: Easy wallet authentication and transaction signing. 🔐
Aptos SDK: Smooth interaction with deployed Move contracts. 🔗

Testing / Dev Tools

Aptos Devnet: Test your dApp with faucet-provided Octas. 🧪
Aptos Explorer: Monitor transactions and contract states: explorer.aptoslabs.com. 🔍


🚀 Getting Started
Follow these steps to set up and run the Aptos Crowdfunding Platform locally! 🎉
1. Clone the Repository
git clone <your-repo-url>
cd crowdfunding-platform

2. Install Frontend Dependencies
cd frontend
npm install

3. Install Aptos CLI
For Windows:
winget install --id AptosCore.aptos --source winget

Verify installation:
aptos --version

4. Fund Your Wallet (Devnet)
Set your wallet address:
export MY_WALLET=0xYourWalletAddress

Fund with faucet (1,000,000,000 Octas):
aptos account fund-with-faucet --account $MY_WALLET --amount 1000000000

Check balance:
aptos account balance --account $MY_WALLET

5. Compile Move Modules
aptos move clean
aptos move compile

6. Run the Frontend
cd frontend
npm run dev

🌐 Open your browser at http://localhost:3000 and connect your Petra Wallet to interact with the smart contracts! 🖥️

🧪 Test Flow
Follow this flow to explore the platform's core features:
1. Mint Soulbound NFT (SBT)

Navigate to Profile → Mint SBT.
Approve the transaction in your Petra Wallet.
Expected: Transaction hash appears. If you try minting again, an "already exists" message will show (this is normal!).

2. Create a Campaign

Fill in:
Goal: 1,000,000 Octas
Milestones: e.g., "Design", "Build"
Milestone Amounts: e.g., 500,000, 500,000


Click Create and approve the transaction.
Expected: Campaign resource is created under your wallet address.

3. Donate to a Campaign

Paste the creator's address.
Enter Amount (e.g., 1,000 Octas).
Click Donate and approve the transaction.
Click Read Raised to verify the total (should show 1,000).
Donate again (e.g., 2,000 Octas) → Raised updates to 3,000.

4. Milestone Voting

Donors vote to approve or reject a milestone.
Approve the transaction in your wallet.
Votes are weighted by donation amount for fairness.

5. Finalize Milestone

Creator clicks Finalize Vote.
Funds are released to the creator's wallet.
Reputation scores are updated for both creator and donors.


🔎 Where to See Results

In-App: View transaction hashes for SBT minting and raised amounts for campaigns.
Petra Wallet: Check the Activity tab for all transactions.
Aptos Explorer: Paste the transaction hash to track details:https://explorer.aptoslabs.com/txn/<HASH>?network=testnet




📝 Notes

Donations: Currently tracked as simple u128 counters.
Voting Weight: Determined by the donation amount for proportional influence.
Compatibility: Fully compatible with Aptos Devnet.
Future Enhancements: Stay tuned for advanced features like multi-currency support and enhanced reputation metrics! 🚀


🎉 Contribute
We welcome contributions! Fork the repo, submit pull requests, or open issues to help improve the platform. Let's build the future of decentralized crowdfunding together! 💪
For questions or support, reach out on GitHub Issues or join our community on Discord. 🌍

Happy Crowdfunding! 🎊