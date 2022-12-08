// https://eips.ethereum.org/EIPS/eip-20
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.8.18;
pragma experimental ABIEncoderV2;

interface Token {

    /// @param _owner The address from which the balance will be retrieved
    /// @return balance the balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transfer(address _to, uint256 _value)  external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return success Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return success Whether the approval was successful or not
    function approve(address _spender  , uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return remaining Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event PendingToApprove(address indexed _from, address indexed _to,uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Reject(address indexed _owner, address indexed _spender, uint256 _value);
}

contract MedErc20 is Token {
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    mapping (address => mapping (address => uint256)) public pendings;
    mapping (address => StructTransferPending[]) public transfer_pending;
    uint256 public pendingTotalSupply;
    uint256 public totalSupply;

    struct StructTransferPending
    {
        address sender;
        uint256 value;
    }
    
    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    constructor(uint256 _initialAmount, string memory _tokenName, string  memory _tokenSymbol) {
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens
        totalSupply = _initialAmount;                        // Update total supply
        name = _tokenName;                                   // Set the name for display purposes
        decimals = 0;                            // Amount of decimals for display purposes
        symbol = _tokenSymbol;                               // Set the symbol for display purposes
    }

    function transfer(address _to, uint256 _value) public override returns (bool success) {
        require(balances[msg.sender] >= _value, "token balance is lower than the value requested");
        require(pendings[msg.sender][_to] == 0, "ya existe una trasferencia en cola");
        balances[msg.sender] -= _value;
        pendings[msg.sender][_to] += _value;
        transfer_pending[_to].push(StructTransferPending(msg.sender,_value));
        pendingTotalSupply += _value;
        emit PendingToApprove(msg.sender, _to, _value);//solhint-disable-line indent, no-unused-vars
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success) {
        require(balances[_from] >= _value, "token balance is lower than the value requested");
        require(pendings[_from][_to] == 0, "ya existe una trasferencia en cola");
        balances[_from] -= _value;
        pendings[_from][_to] += _value;
        transfer_pending[_to].push(StructTransferPending(_from,_value));
        pendingTotalSupply += _value;
        emit PendingToApprove(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance) {
        return balances[_owner];
    }

    function approveTransfer(address _spender,uint256 _value) public returns (bool success)
    {
        require(pendings[_spender][msg.sender]==_value);        
        pendings[_spender][msg.sender] -= _value;
        for(uint i=0 ; i < transfer_pending[msg.sender].length; i++)
        {
            if(transfer_pending[msg.sender][i].sender ==_spender)
            {
                remove(i);
                break;
            }
        }
        balances[msg.sender] += _value;
        emit Transfer(_spender, msg.sender, _value);
        pendingTotalSupply -= _value;
        return true;
    }

    function rejectTransfer(address _spender,uint256 _value) public returns (bool success)
    {
        require(pendings[_spender][msg.sender]==_value); 
        pendings[_spender][msg.sender] -= _value;
        for(uint i=0 ; i < transfer_pending[msg.sender].length; i++)
        {
            if(transfer_pending[msg.sender][i].sender==_spender)
            {
                remove(i);
                break;
            }
        }
        balances[_spender] += _value;
        emit Reject(_spender, msg.sender, _value);
        pendingTotalSupply -= _value;
        return true;
    }

    function transferPendingToApprove(address _owner) public view returns (StructTransferPending[] memory pending)
    {
       return transfer_pending[_owner];   
    }

    function approve(address _spender, uint256 _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    function remove(uint index) private
    {
        for(uint i = index; i < transfer_pending[msg.sender].length - 1 ; i++)
        {
            transfer_pending[msg.sender][i] = transfer_pending[msg.sender][i+1];
        }
        transfer_pending[msg.sender].pop();

    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }
}