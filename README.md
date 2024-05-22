# FundMe Contract

## Overview
The `FundMe` contract is a decentralized crowdfunding solution that allows users to contribute funds to a campaign. The campaign creator can withdraw the funds and distribute unique SVG-ERC721 tokens to all contributors as a thank you.

### Fund Campaign
- **Description:** Allows anyone to contribute to the campaign with a minimum amount of 0.01 ether.
- **Details:** 
  - Ensures the funding amount is at least 0.01 ether.
  - Adds unique contributors to a list for potential airdrop of tokens.

### Withdraw Funds
- **Description:** Allows the campaign creator to withdraw all collected funds.
- **Details:** 
  - Resets the list of funders.
  - Transfers the entire balance to the campaign creator.

### Withdraw Funds with Airdrop
- **Description:** Allows the campaign creator to withdraw all collected funds and airdrop SVG-ERC721 tokens to all contributors.
- **Details:**
  - Mints and sends an ERC721 token to each contributor.
  - Resets the list of funders.
  - Transfers the entire balance to the campaign creator.
