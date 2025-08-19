import { Aptos, AptosConfig, Network } from '@aptos-labs/ts-sdk';

// Network and module address can be overridden via Vite env
const VITE_NETWORK = (import.meta?.env?.VITE_APTOS_NETWORK || 'testnet').toLowerCase();
const NETWORK_MAP = { mainnet: Network.MAINNET, testnet: Network.TESTNET, devnet: Network.DEVNET, local: Network.LOCAL };
const aptosConfig = new AptosConfig({ network: NETWORK_MAP[VITE_NETWORK] || Network.TESTNET });
export const aptos = new Aptos(aptosConfig);

// Deployed named address from Move.toml (can be overridden by env)
export const MODULE_ADDRESS = import.meta?.env?.VITE_MODULE_ADDRESS || '0x9ce046321625a09930e99225893361acc43c66b7232430895b1c188ddae4da82';

export const CAMPAIGN_MODULE = `${MODULE_ADDRESS}::campaign`;
export const SBT_MODULE = `${MODULE_ADDRESS}::sbt`;

export function stringToBytes(str) {
  return new TextEncoder().encode(str);
}

// Fetch campaign resource stored under creator address
export async function fetchCampaignResource(creatorAddress) {
  try {
    const resourceType = `${MODULE_ADDRESS}::campaign::Campaign`;
    const res = await aptos.getAccountResource({ accountAddress: creatorAddress, resourceType });
    return res;
  } catch (e) {
    return null;
  }
}

// Build a ts-sdk simple transaction payload for wallet adapters
export function buildEntryFunction(functionFullName, functionArguments, typeArguments = []) {
  return {
    data: {
      function: functionFullName,
      typeArguments,
      functionArguments,
    },
  };
}


