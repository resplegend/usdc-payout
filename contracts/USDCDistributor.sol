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

    // Recipients and their distribution percentages
    address[] public recipients;
    uint256 public recipientsPercent; // e.g., 9000 for 90.00%

    // Reward address and its percentage
    address public rewardAddress;
    uint256 public rewardPercent; // e.g., 1000 for 10.00%

    uint256 public lastDistributed;
    uint256 public distributionAmount; // Amount to distribute per call, in USDC's smallest unit

    event Distributed(uint256 totalAmount, uint256 timestamp);
    event RecipientsUpdated(address[] recipients, uint256 recipientsPercent);
    event RewardsDataUpdated(address rewardAddress, uint256 rewardPercent);
    event Withdrawn(address to, uint256 amount);

    function initialize(
        address usdcAddress,
        address[] memory _recipients,
        uint256 _recipientsPercent,
        address _rewardAddress,
        uint256 _rewardPercent,
        uint256 _distributionAmount
    ) public initializer {
        __Ownable_init(msg.sender);
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DISTRIBUTOR_ROLE, msg.sender);
        
        require(_recipients.length > 0, "No recipients");
        require(
            _recipientsPercent + _rewardPercent == 10000,
            "Percents must sum to 10000"
        );
        usdc = ERC20Upgradeable(usdcAddress);
        recipients = _recipients;
        recipientsPercent = _recipientsPercent;
        rewardAddress = _rewardAddress;
        rewardPercent = _rewardPercent;
        distributionAmount = _distributionAmount;
    }

    function setRecipients(
        address[] calldata _recipients,
        uint256 _recipientsPercent
    ) external onlyOwner {
        require(_recipients.length > 0, "No recipients");
        require(
            _recipientsPercent + rewardPercent == 10000,
            "Percents must sum to 10000"
        );
        recipients = _recipients;
        recipientsPercent = _recipientsPercent;
        emit RecipientsUpdated(_recipients, _recipientsPercent);
    }

    function setRewardsData(
        address _rewardAddress,
        uint256 _rewardPercent
    ) external onlyOwner {
        require(_rewardAddress != address(0), "Zero address");
        require(
            recipientsPercent + _rewardPercent == 10000,
            "Percents must sum to 10000"
        );
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
        require(
            recipientsPercent + rewardPercent == 10000,
            "Percents must sum to 10000"
        );
        uint256 balance = usdc.balanceOf(address(this));
        require(balance >= distributionAmount, "Insufficient USDC");

        uint256 toRecipients = (distributionAmount * recipientsPercent) / 10000;
        uint256 perRecipient = toRecipients / recipients.length;

        // Distribute to recipients
        for (uint256 i = 0; i < recipients.length; i++) {
            usdc.transfer(recipients[i], perRecipient);
        }
        // Send remainder to reward address (handles dust)
        uint256 sentToRecipients = perRecipient * recipients.length;
        uint256 rewardAmount = distributionAmount - sentToRecipients;
        usdc.transfer(rewardAddress, rewardAmount);

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
