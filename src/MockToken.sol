// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MockToken is ERC20, Ownable {
    // Variables
    uint8 private decimals_;

    constructor(string memory name, string memory symbol, uint8 _decimals, uint256 initialSupply)
        ERC20(name, symbol)
        Ownable(msg.sender)
    {
        decimals_ = _decimals;
        _mint(msg.sender, initialSupply);
    }

    // Functions

    /**
     * @dev function to mint new tokens
     * @param to address to recieve tokens
     * @param amount to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev function to burn a number of token
     * @param amount of token to burn
     */
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev function to get number of tokens decimals
     * @return number of decimals
     */
    function decimals() public view override returns (uint8) {
        return decimals_;
    }
}
