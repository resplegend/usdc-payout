// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract USDCDistributor is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    ERC20Upgradeable public usdc;

    // Admin role for distribution
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    // Recipients
    address[] public recipients;

    // Reward address and its percentage
    address public rewardAddress;
    uint256 public rewardPercent; // e.g., 1000 for 10.00%

    uint256 public lastDistributed;
    uint256 public distributionAmount; // Amount to distribute per call, in USDC's smallest unit

    event Distributed(uint256 totalAmount, uint256 timestamp);
    event RecipientsUpdated(address[] recipients);
    event RewardsDataUpdated(address rewardAddress, uint256 rewardPercent);
    event Withdrawn(address to, uint256 amount);

    function initialize(
        address usdcAddress,
        address[] memory _recipients,
        address _rewardAddress,
        uint256 _rewardPercent,
        uint256 _distributionAmount
    ) public initializer {
        __Ownable_init(msg.sender);
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        
        require(_recipients.length > 0, "No recipients");

        usdc = ERC20Upgradeable(usdcAddress);
        recipients = _recipients;
        rewardAddress = _rewardAddress;
        rewardPercent = _rewardPercent;
        distributionAmount = _distributionAmount;
    }

    function setRecipients(
        address[] calldata _recipients
    ) external onlyOwner {
        require(_recipients.length > 0, "No recipients");

        recipients = _recipients;

        emit RecipientsUpdated(_recipients);
    }

    function setRewardsData(
        address _rewardAddress,
        uint256 _rewardPercent
    ) external onlyOwner {
        require(_rewardAddress != address(0), "Zero address");

        rewardAddress = _rewardAddress;
        rewardPercent = _rewardPercent;

        emit RewardsDataUpdated(_rewardAddress, _rewardPercent);
    }

    function setDistributionAmount(
        uint256 _distributionAmount
    ) external onlyOwner {
        require(_distributionAmount > 0, "Amount must be > 0");
        distributionAmount = _distributionAmount;
    }

    function distribute() external onlyRole(DISTRIBUTOR_ROLE) {
        require(recipients.length > 0, "No recipients");
        require(rewardAddress != address(0), "No reward address");

        uint256 balance = usdc.balanceOf(address(this));
        require(balance >= distributionAmount, "Insufficient USDC");

        uint256 rewardAmount = distributionAmount * rewardPercent / 11000;
        usdc.transfer(rewardAddress, rewardAmount);

        uint256 remainingAmount = distributionAmount - rewardAmount;
        uint256 perRecipient = remainingAmount / recipients.length;

        // Distribute to recipients
        for (uint256 i = 0; i < recipients.length; i++) {
            usdc.transfer(recipients[i], perRecipient);
        }

        lastDistributed = block.timestamp;
        emit Distributed(distributionAmount, block.timestamp);
    }

    function withdraw(address to, uint256 amount) external onlyOwner {
        require(to != address(0), "Zero address");
        require(amount > 0, "Amount must be > 0");
        require(usdc.balanceOf(address(this)) >= amount, "Insufficient USDC");
        usdc.transfer(to, amount);

        emit Withdrawn(to, amount);
    }
}
