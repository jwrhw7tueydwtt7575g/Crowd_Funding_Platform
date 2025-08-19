import React from 'react';
import { NavLink } from 'react-router-dom';
import ConnectWallet from './ConnectWallet';

function Navbar() {
  return (
    <header style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: 12 }}>
      <nav style={{ display: 'flex', gap: 16 }}>
        <NavLink to="/" style={({ isActive }) => ({ color: isActive ? '#646cff' : 'inherit' })}>Home</NavLink>
        <NavLink to="/campaigns" style={({ isActive }) => ({ color: isActive ? '#646cff' : 'inherit' })}>Campaigns</NavLink>
        <NavLink to="/create" style={({ isActive }) => ({ color: isActive ? '#646cff' : 'inherit' })}>Create</NavLink>
        <NavLink to="/profile" style={({ isActive }) => ({ color: isActive ? '#646cff' : 'inherit' })}>Profile</NavLink>
      </nav>
      <ConnectWallet />
    </header>
  );
}

export default Navbar;


