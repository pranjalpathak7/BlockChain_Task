// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error NotOwner();
error AddressNotUnique();

contract FundMe {
    mapping(address => uint256) public addressToAmountFunded;
    mapping(address => bool) public isFunder; // Mapping to track unique funders
    address[] public funders;
    address public i_owner;

    uint256 public constant MINIMUM_ETH = 0.05 ether; // Minimum contribution in ether

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value >= MINIMUM_ETH, "You need to spend more ETH!");
        require(!isFunder[msg.sender], "You've already funded");

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        isFunder[msg.sender] = true;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        i_owner = newOwner;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        delete funders;
        
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Not owner");
        _;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
