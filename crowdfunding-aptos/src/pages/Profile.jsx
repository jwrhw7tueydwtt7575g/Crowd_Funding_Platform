import React, { useState } from 'react';
import { Button } from 'antd';
import { useWallet } from '@aptos-labs/wallet-adapter-react';
import { SBT_MODULE, buildEntryFunction } from '../aptosClient';

function Profile() {
  const { account, signAndSubmitTransaction } = useWallet();
  const [txHash, setTxHash] = useState('');

  async function mintSbt() {
    if (!account) return;
    const payload = buildEntryFunction(`${SBT_MODULE}::mint_sbt`, [
      new TextEncoder().encode('Crowdfund'),
      new TextEncoder().encode('Contributor'),
      new TextEncoder().encode('https://example.com/sbt.json'),
      account.address,
    ]);
    const tx = await signAndSubmitTransaction(payload);
    setTxHash(tx.hash);
  }

  return (
    <div style={{ padding: 24, display: 'flex', flexDirection: 'column', gap: 16, alignItems: 'center' }}>
      <h2 style={{ marginTop: 24 }}>Profile</h2>
      <div style={{ opacity: 0.8 }}>Address: {account?.address ?? '-'}</div>
      <Button type="primary" onClick={mintSbt} disabled={!account} style={{ minWidth: 240 }}>Mint SBT</Button>
      {txHash ? <div style={{ fontFamily: 'monospace', fontSize: 12 }}>Tx: {txHash}</div> : null}
    </div>
  );
}

export default Profile;


