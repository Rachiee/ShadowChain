# ShadowChain Smart Contract

## Overview
**ShadowChain** is a blockchain-based smart contract for creating, owning, and battling unique NFT characters. Players can mint their characters, upgrade them, and engage in strategic battles to determine supremacy in the ShadowChain arena. This contract leverages the power of blockchain to ensure transparency, security, and ownership.

---

## Features
1. **Character Creation**  
   - Mint unique NFT characters with varying attributes and rarities.
   - Rarities include: **common**, **rare**, and **legendary**, which influence character stats.

2. **Character Ownership**  
   - Ownership of each character is tracked using a mapping system, ensuring characters belong to specific wallet addresses.

3. **Battles**  
   - Engage in battles where characters' attack and defense stats determine the winner.
   - Battle outcomes are recorded in a decentralized battle history.

4. **Level Up**  
   - Owners can level up their characters, increasing their stats and enhancing their battle capabilities.

5. **Transparent Gameplay**  
   - All character data, ownership details, and battle records are stored on-chain, allowing players to verify outcomes.

---

## Smart Contract Details
### Contract Name: **ShadowChain**

### Key Data Structures
- **Characters**  
  A map storing character attributes:
  ```clarity
  (define-map characters 
    {id: uint} 
    {
      name: (string-ascii 50),
      attack: uint,
      defense: uint,
      health: uint,
      level: uint,
      rarity: (string-ascii 20)
    }
  )
  ```

- **Character Owners**  
  A map linking characters to their owners:
  ```clarity
  (define-map character-owners 
    {character-id: uint} 
    {owner: principal}
  )
  ```

- **Battle History**  
  A record of all battles fought:
  ```clarity
  (define-map battle-history 
    {battle-id: uint} 
    {
      attacker-id: uint, 
      defender-id: uint, 
      winner-id: uint,
      timestamp: uint
    }
  )
  ```

---

## Public Functions
### 1. `create-character`
- **Purpose**: Mint a new character.
- **Inputs**: 
  - `name`: Name of the character.
  - `rarity`: Rarity level (**common**, **rare**, **legendary**).
- **Output**: The ID of the newly created character.

---

### 2. `battle`
- **Purpose**: Engage two characters in a battle.
- **Inputs**:
  - `attacker-id`: ID of the attacking character.
  - `defender-id`: ID of the defending character.
- **Output**: The ID of the winning character.

---

### 3. `level-up`
- **Purpose**: Upgrade a character's stats by leveling up.
- **Input**: 
  - `character-id`: The ID of the character to level up.
- **Output**: Boolean indicating success.

---

### Read-only Functions
1. `get-character-details`: Fetch details of a specific character by ID.  
2. `get-character-owner`: Fetch the owner of a character by ID.

---

## Error Codes
- **ERR-NOT-OWNER** (`u100`): The user is not the owner of the character.  
- **ERR-INVALID-CHARACTER** (`u101`): The character ID does not exist.  
- **ERR-INSUFFICIENT-FUNDS** (`u102`): Insufficient funds for the operation.  
- **ERR-BATTLE-NOT-ALLOWED** (`u103`): Characters owned by the same user cannot battle each other.

---

## Minting Fee
- The minting fee is set to **0.1 STX** by default.

---

## How It Works
1. **Minting a Character**  
   Players pay the minting fee to create a character. The character's attributes are initialized based on its rarity. Ownership is assigned to the payer's wallet address.

2. **Battling**  
   Players pit their characters against each other. The character with higher stats wins, and the result is stored in the blockchain.

3. **Leveling Up**  
   Players can enhance their characters by leveling up, boosting their attack, defense, and health.

---

## Future Enhancements
- Introducing power-ups and special abilities.
- Adding staking mechanics for rewards.
- Enabling marketplace functionality for trading characters.

---

**Join the ShadowChain Arena**  
Dive into the world of fierce battles and legendary characters. Forge your destiny and become a legend in the ShadowChain universe!