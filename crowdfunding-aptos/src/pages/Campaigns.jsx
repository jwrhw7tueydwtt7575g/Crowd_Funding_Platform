import React, { useState } from 'react';
import { Input, Button } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import { aptos, CAMPAIGN_MODULE, buildEntryFunction, fetchCampaignResource } from '../aptosClient';

function Campaigns() {
  const { account, signAndSubmitTransaction } = useWallet();
  const [creatorAddress, setCreatorAddress] = useState('');
  const [raised, setRaised] = useState(null);
  const [donation, setDonation] = useState('0');

  async function handleDonate() {
    if (!account) return;
    const amount = Number(donation);
    const payload = buildEntryFunction(`${CAMPAIGN_MODULE}::donate`, [creatorAddress, amount]);
    const tx = await signAndSubmitTransaction(payload);
    await aptos.waitForTransaction({ transactionHash: tx.hash });
  }

  async function fetchRaised() {
    try {
      const view = await aptos.view({
        payload: {
          function: `${CAMPAIGN_MODULE}::get_raised`,
          functionArguments: [creatorAddress],
        }
      });
      setRaised(String(view[0] ?? '0'));
    } catch (e) {
      const res = await fetchCampaignResource(creatorAddress);
      if (res && res.data && typeof res.data.raised !== 'undefined') {
        setRaised(String(res.data.raised));
      } else {
        setRaised('N/A');
      }
    }
  }

  return (
    <div style={{ padding: 24, display: 'flex', flexDirection: 'column', gap: 12, alignItems: 'center' }}>
      <h2>Donate to Campaign</h2>
      <Input style={{ maxWidth: 520 }} placeholder="Creator address (campaign_addr)" value={creatorAddress} onChange={(e) => setCreatorAddress(e.target.value)} />
      <Input style={{ maxWidth: 520 }} placeholder="Amount (Octas)" value={donation} onChange={(e) => setDonation(e.target.value)} />
      <div style={{ display: 'flex', gap: 8 }}>
        <Button type="primary" onClick={handleDonate} disabled={!account}>Donate</Button>
        <Button onClick={fetchRaised}>Read Raised</Button>
      </div>
      <div>Raised: {raised ?? '-'}</div>
      {!account ? <div style={{ opacity: 0.8 }}>Connect wallet to donate</div> : null}
    </div>
  );
}

export default Campaigns;


