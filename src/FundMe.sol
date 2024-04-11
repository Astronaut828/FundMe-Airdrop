// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/*

  /$$$$$$                            /$$       /$$$$$$$$ /$$$$$$$$ /$$   /$$ /$$
 /$$__  $$                          | $$      | $$_____/|__  $$__/| $$  | $$| $$
| $$  \__/  /$$$$$$  /$$$$$$$   /$$$$$$$      | $$         | $$   | $$  | $$| $$
|  $$$$$$  /$$__  $$| $$__  $$ /$$__  $$      | $$$$$      | $$   | $$$$$$$$| $$
 \____  $$| $$$$$$$$| $$  \ $$| $$  | $$      | $$__/      | $$   | $$__  $$|__/
 /$$  \ $$| $$_____/| $$  | $$| $$  | $$      | $$         | $$   | $$  | $$    
|  $$$$$$/|  $$$$$$$| $$  | $$|  $$$$$$$      | $$$$$$$$   | $$   | $$  | $$ /$$
 \______/  \_______/|__/  |__/ \_______/      |________/   |__/   |__/  |__/|__/
                                                                                                                                                                                                
*/
/**
 *  @title A contract to crowd fund your ideas
 *  @notice Allows the campaign creator to withdraw all the funds and airdrop a SVG-ERC721 token to all funders.
 *  @author Astronaut828
 */

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/utils/Base64.sol";

// @spec error thrown when the caller is not the campaign creator of the contract.
error FundMe__NotCampaignCreator();

contract FundMe is ERC721 {
    uint256 private _tokenId;
    address private immutable _campaignCreator;
    address[] private funders;
    mapping(address => bool) private funderExists;

    modifier onlyCampaignCreator() {
        if (msg.sender != _campaignCreator) revert FundMe__NotCampaignCreator();
        _;
    }

    constructor() ERC721("123456789X12", "CampaignSymbol") {
        _campaignCreator = msg.sender;
        _tokenId = 0;
    }

    // @spec allows the contract to receive ether even if no function is called.
    fallback() external payable {
        fund();
    }

    // @spec fund function allows anyone to fund the contract.
    // @dev requires a minimum funding amount of 0.01 ether.
    // @dev adds the funder to the list of unique funders for airdrop option.
    function fund() public payable {
        require(msg.value >= 0.01 ether, "Your funding amount is too low.");
        // Add unique funder to the list
        if (!funderExists[msg.sender]) {
            funders.push(msg.sender);
            funderExists[msg.sender] = true;
        }
    }

    // @spec withdraw function allows the campaign creator to withdraw all the funds from the contract.
    // @dev list of funders is reset and the balance is transferred to the campaign creator.
    function withdraw() public onlyCampaignCreator {
        // Delete all funders
        delete funders;

        // Transfer the contract balance to the campaign creator
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // @spec withdraw with airdrop
    // @dev lets the campaign creator withdraw all the funds and airdrop a SVG-ERC721 token to all funders.
    function withdrawWithAirdrop() public onlyCampaignCreator {
        // Airdrop ERC721 token to all funders
        for (uint256 i = 0; i < funders.length; i++) {
            _mint(funders[i], _tokenId);
            _tokenId++;
        }

        delete funders;

        // Transfer the contract balance to the campaign creator
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // @spec function to build tokenURI for the ERC721 token
    // @dev returns a SVG image of the FundMe contract.
    function tokenURI(uint256 /* tokenId */ ) public view override returns (string memory) {
        string memory campaignName = name(); // Fetch the campaign name

        // Start building the SVG string
        string memory svgPart1 = string(
            abi.encodePacked(
                '<?xml version="1.0" encoding="UTF-8"?>',
                '<svg xmlns="http://www.w3.org/2000/svg" version="1.1" viewBox="0 0 400 400" preserveAspectRatio="xMidYMid meet">',
                '<style type="text/css">',
                "<![CDATA[",
                "text { font-family: monospace; }",
                ".h1 { font-size: 60px; }",
                ".h2 { font-size: 40px; }",
                ".h3 { font-size: 50px; }",
                ".emoji { font-size: 60px; }",
                "]]>",
                "</style>",
                '<rect x="0" y="0" width="400" height="400" fill="#D3D3D3" stroke="black" stroke-width="6"/>',
                '<text class="h1" x="20" y="80">Thank You</text>',
                '<text class="h2" x="20" y="130">for funding:</text>',
                '<text class="h3" x="20" y="220">'
            )
        );

        string memory svgPart2 =
            string(abi.encodePacked("</text>", '<text class="emoji" x="20" y="310">&#x2764;</text>', "</svg>"));

        // Concatenating the SVG parts with the campaign name
        string memory finalSvg = string(abi.encodePacked(svgPart1, campaignName, svgPart2));

        // Encoding the entire SVG string in Base64
        string memory svgBase64Encoded = Base64.encode(bytes(finalSvg));

        // Constructing the tokenURI with the SVG embedded as Base64
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"FundMe Receipt", "description":"This NFT is a thank you note for funding a dream through FundMe.", "image":"data:image/svg+xml;base64,',
                            svgBase64Encoded,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    // returns number of unique funders
    function getFunders() public view returns (uint256) {
        return funders.length;
    }
}
