// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    
    mapping(address=>uint256) lockedAmount;
    address owner;
    bool paused;

    error NotEnoughAmount();
    error AccessDenied();
    error Paused();
    error InsufficientBalance();
    error WithdrawFailed();

    constructor(){
        owner = msg.sender;
    }

    modifier checkPaused() {
        if(paused){
            revert Paused();
        } else {
            _;
        }
    }

    function Deposit() checkPaused external payable {
        require(msg.value>0, "Vault) deposit more than 0");
        lockedAmount[msg.sender]+=msg.value;
    }
    
    function Withdraw(uint256 amount) checkPaused nonReentrant external payable{
        if (amount>lockedAmount[msg.sender]){
            revert InsufficientBalance();
        }
        require(lockedAmount[msg.sender]>=0, "Vault) no funds to withdraw");
        lockedAmount[msg.sender] -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    function AdminWithdraw(uint256 amount) checkPaused nonReentrant external payable {
        if (amount>address(this).balance){
            revert InsufficientBalance();
        }
        if (msg.sender != owner){
            revert AccessDenied();
        }
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    receive() checkPaused external payable {
        lockedAmount[msg.sender]+=msg.value;
    }
}
