import React, { useMemo, useState } from 'react';
import { useWallet } from '@aptos-labs/wallet-adapter-react';

function truncateAddress(addr) {
  if (!addr) return '';
  return addr.slice(0, 6) + '...' + addr.slice(-4);
}

function ConnectWallet() {
  const { wallets, account, wallet, connect, disconnect } = useWallet();
  const [open, setOpen] = useState(false);

  const availableWallets = useMemo(() => wallets || [], [wallets]);
  const petraWallet = useMemo(() => availableWallets.find((w) => /petra/i.test(w.name)), [availableWallets]);

  async function onConnect(name) {
    try {
      await connect(name);
      setOpen(false);
    } catch (e) {
      // no-op, surface via console only to avoid noisy UI
      // eslint-disable-next-line no-console
      console.error('Wallet connect failed:', e);
    }
  }

  async function onDisconnect() {
    try {
      await disconnect();
    } catch (e) {
      // eslint-disable-next-line no-console
      console.error('Wallet disconnect failed:', e);
    }
  }

  async function connectPetra() {
    if (petraWallet) {
      await onConnect(petraWallet.name);
      return;
    }
    const installUrl = 'https://petra.app/';
    window.open(installUrl, '_blank');
  }

  return (
    <div style={{ position: 'relative', display: 'flex', gap: 8 }}>
      {account ? (
        <button onClick={onDisconnect}>
          {truncateAddress(account.address)} · Disconnect
        </button>
      ) : (
        <>
          <button onClick={connectPetra}>Connect with Petra</button>
          <button onClick={() => setOpen((v) => !v)}>Other wallets</button>
        </>
      )}
      {!account && open ? (
        <div style={{
          position: 'absolute',
          right: 0,
          top: '100%',
          marginTop: 8,
          background: 'white',
          color: '#213547',
          border: '1px solid rgba(0,0,0,0.1)',
          borderRadius: 8,
          padding: 8,
          minWidth: 220,
          zIndex: 1000,
          boxShadow: '0 6px 24px rgba(0,0,0,0.06)'
        }}>
          {availableWallets.length === 0 ? (
            <div style={{ padding: 8 }}>No wallets detected. Try installing Petra.</div>
          ) : (
            availableWallets.map((w) => (
              <button
                key={w.name}
                onClick={() => onConnect(w.name)}
                style={{
                  width: '100%',
                  textAlign: 'left',
                  padding: 10,
                  marginBottom: 6,
                  borderRadius: 8,
                }}
              >
                {w.name}
              </button>
            ))
          )}
        </div>
      ) : null}
    </div>
  );
}

export default ConnectWallet;


