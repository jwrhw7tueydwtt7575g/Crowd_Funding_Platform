import React from 'react';

function Home() {
  return (
    <div style={{
      padding: 24,
      display: 'flex',
      flexDirection: 'column',
      gap: 12,
      alignItems: 'center',
      textAlign: 'center',
    }}>
      <h1 style={{ marginTop: 32 }}>Crowdfunding on Aptos</h1>
      <p style={{ maxWidth: 720, opacity: 0.9 }}>
        Create campaigns, donate with AptosCoin, and track milestone-based releases.
      </p>
    </div>
  );
}

export default Home;


