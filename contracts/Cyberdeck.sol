// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SafeMath } from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
contract wallet vault type system
visor
https://github.com/VisorFinance/VisorFactory/blob/master/contracts/visor/Visor.sol
*/

contract Cyberdeck {
    using SafeMath for uint256;

    address payable public owner;

    event LogETHDeposit(address indexed sender, uint amount);
    event LogETHWithdrawal(address indexed owner, uint amount);
    event LogETHTransfer(address indexed recipient, uint amount);
    event LogTokenTransfer(address indexed token, address indexed recipient, uint amount);

    constructor(address _owner) payable {
        owner = payable(_owner);
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(owner == msg.sender, "Cyberdeck: caller is not the owner.");
        _;
    }

    function depositETH() public payable {
        require(msg.value > 0, "Cyberdeck: ETH deposit has no ETH.");
        emit LogETHDeposit(msg.sender, msg.value);
    }

    function getETHBalance() public view returns (uint) {
        return address(this).balance;
    }

    function withdrawETH(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Cyberdeck: not enough ETH for withdraw.");
        owner.transfer(amount);
        emit LogETHWithdrawal(msg.sender, amount);
    }

    function transferETH(address payable recipient, uint amount) public onlyOwner {
        require(recipient != address(0), "Cyberdeck: cannot transfer to 0x0.");
        require(address(this).balance >= amount, "Cyberdeck: not enough ETH for transfer.");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Cyberdeck: unable to send ETH, recipient may have reverted");
        emit LogETHTransfer(recipient, amount);
    }

    function transferERC20(address token, address to, uint amount) public onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= amount, "Cyberdeck: token balance insufficient");
        IERC20(token).transfer(to, amount);
        emit LogTokenTransfer(token, to, amount);
    }

    // function getTokenBalance(tokenAddress)
    // function lock(tokenAddress, amount) [permission signature]
    // function rageQuit()

}

contract CyberdeckSweatshop {
    uint256 public numberOfCyberdecks;
    Cyberdeck[] public cyberdecks;
    mapping (address => address[]) private deckowners;

    event NewCyberdeck(address indexed owner, address indexed cyberdeck);

    function _createCyberdeck() internal returns (address) {
        Cyberdeck deck = new Cyberdeck(msg.sender);
        cyberdecks.push(deck);
        deckowners[msg.sender].push(address(deck));
        numberOfCyberdecks++;

        emit NewCyberdeck(msg.sender, address(deck));
        return address(deck);
    }

    function _createCyberdeckAndSendEther() internal returns (address) {
        Cyberdeck deck = (new Cyberdeck){value: msg.value}(msg.sender);
        cyberdecks.push(deck);
        deckowners[msg.sender].push(address(deck));
        numberOfCyberdecks++;

        emit NewCyberdeck(msg.sender, address(deck));
        return address(deck);
    }
    
    function create() external payable returns (address) {
        if (msg.value > 0) {
            return _createCyberdeckAndSendEther();
        } else {
            return _createCyberdeck();
        }
    }
}
