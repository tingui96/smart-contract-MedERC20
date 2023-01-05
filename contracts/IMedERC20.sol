// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IMedERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event PendingApprove(address indexed from,address indexed to, uint256 value);
    /**
     * @dev Emitted when `to` reject the transfer from 'from'
     *
     * Note that `value` may be zero.
     */
    event RejectTransfer(address indexed from,address indexed to, uint256 value);
    /**
     * @dev Returns the amount of tokens pending.
     */
    function pendingTotalSupply() external view returns (uint256);
    /**
     * @dev Moves `amount` tokens pending from the caller's account to balance account.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function approveTransfer(address from, uint256 amount) external returns (bool);
    /**
     * @dev Moves `amount` tokens pending from the caller's account to 'from' balance account.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function rejectTransfer(address from, uint256 amount) external returns (bool);

}
