// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";


/**
 * @title LendingProtocol
 * @author Axie
 * @dev A DeFi lending and borrowing protocol that allows users to:
 * - Deposit tokens to earn interest
 * - Borrow tokens against their deposited collateral
 * - Use off-chain signatures for gasless operations
 * - Manage collateralization ratios and liquidation
 */
contract LendingProtocol is Ownable, ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // Structs
    struct User {
        uint256 totalDeposited;      // Total amount deposited by user
        uint256 totalBorrowed;       // Total amount borrowed by user
        uint256 lastUpdateTime;      // Last time user's data was updated
        bool isActive;               // Whether user has active positions
    }

    struct Market {
        IERC20 token;                // The token being lent/borrowed
        uint256 totalSupply;         // Total amount supplied to this market
        uint256 totalBorrow;         // Total amount borrowed from this market
        uint256 supplyRate;          // Current supply rate (APY in basis points)
        uint256 borrowRate;          // Current borrow rate (APY in basis points)
        uint256 collateralFactor;    // Collateral factor (0-10000, where 10000 = 100%)
        bool isActive;               // Whether this market is active
    }

    struct SignatureData {
        uint256 nonce;               // Unique nonce for signature
        uint256 deadline;            // Signature expiration time
        bytes signature;             // ECDSA signature
    }

    // State variables
    mapping(address => User) public users;
    mapping(address => mapping(address => uint256)) public userDeposits; // user => token => amount
    mapping(address => mapping(address => uint256)) public userBorrows;  // user => token => amount
    mapping(address => Market) public markets;
    mapping(address => uint256) public userNonces;
    
    address[] public supportedTokens;
    uint256 public constant LIQUIDATION_THRESHOLD = 8000; // 80% in basis points
    uint256 public constant LIQUIDATION_PENALTY = 500;    // 5% in basis points
    uint256 public constant BASIS_POINTS = 10000; // this is variable to calculate precent

    // Events
    event MarketAdded(address indexed token, uint256 collateralFactor);
    event MarketUpdated(address indexed token, uint256 collateralFactor);
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Withdraw(address indexed user, address indexed token, uint256 amount);
    event Borrow(address indexed user, address indexed token, uint256 amount);
    event Repay(address indexed user, address indexed token, uint256 amount);
    event Liquidate(address indexed liquidator, address indexed user, address indexed token, uint256 amount);
    event RatesUpdated(address indexed token, uint256 supplyRate, uint256 borrowRate);

    // Modifiers
    modifier onlyActiveMarket(address token) {
        require(markets[token].isActive, "Market not active");
        _;
    }

    modifier onlyValidSignature(SignatureData calldata sigData) {
        require(block.timestamp <= sigData.deadline, "Signature expired");
        require(userNonces[msg.sender] == sigData.nonce, "Invalid nonce");
        _;
        userNonces[msg.sender]++;
    }

    /**
     * @dev Constructor to initialize the protocol
     */
    constructor () Ownable(msg.sender){}

    /**
     * @dev Add a new market to the protocol
     * @param token The ERC20 token to add
     * @param collateralFactor The collateral factor for this token (0-10000)
     * @param initialSupplyRate Initial supply rate in basis points
     * @param initialBorrowRate Initial borrow rate in basis points
     */
    function addMarket(
        address token,
        uint256 collateralFactor,
        uint256 initialSupplyRate,
        uint256 initialBorrowRate
    ) external onlyOwner {
        require(token != address(0), "Invalid token address");
        require(collateralFactor <= BASIS_POINTS, "Invalid collateral factor");
        require(!markets[token].isActive, "Market already exists");

        markets[token] = Market({
            token: IERC20(token),
            totalSupply: 0,
            totalBorrow: 0,
            supplyRate: initialSupplyRate,
            borrowRate: initialBorrowRate,
            collateralFactor: collateralFactor,
            isActive: true
        });

        supportedTokens.push(token);
        emit MarketAdded(token, collateralFactor);
    }
}
