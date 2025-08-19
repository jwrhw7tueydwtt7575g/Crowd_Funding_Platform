import React, { useState } from 'react';
import { Input, Button } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import { CAMPAIGN_MODULE, buildEntryFunction } from '../aptosClient';

function CreateCampaign() {
  const { account, signAndSubmitTransaction } = useWallet();
  const [goal, setGoal] = useState('0');
  const [milestones, setMilestones] = useState('Build,MVP,Launch');
  const [amounts, setAmounts] = useState('100,200,300');

  async function handleCreate() {
    if (!account) return;
    const descriptions = milestones.split(',').map((s) => new TextEncoder().encode(s.trim()));
    const amountsVec = amounts.split(',').map((s) => Number(s.trim()));

    const payload = buildEntryFunction(`${CAMPAIGN_MODULE}::create_campaign`, [
      Number(goal),
      descriptions,
      amountsVec,
    ]);
    const tx = await signAndSubmitTransaction(payload);
    console.log('tx', tx.hash);
  }

  return (
    <div style={{ padding: 24, display: 'flex', flexDirection: 'column', gap: 12, alignItems: 'center' }}>
      <h2>Create Campaign</h2>
      <Input style={{ maxWidth: 520 }} placeholder="Goal (Octas)" value={goal} onChange={(e) => setGoal(e.target.value)} />
      <Input style={{ maxWidth: 520 }} placeholder="Milestone descriptions (comma-separated)" value={milestones} onChange={(e) => setMilestones(e.target.value)} />
      <Input style={{ maxWidth: 520 }} placeholder="Milestone amounts (comma-separated octas)" value={amounts} onChange={(e) => setAmounts(e.target.value)} />
      <Button type="primary" onClick={handleCreate} disabled={!account} style={{ minWidth: 240 }}>Create</Button>
      {!account ? <div style={{ opacity: 0.8 }}>Connect wallet to create campaign</div> : null}
    </div>
  );
}

export default CreateCampaign;


