// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
 
contract TimeLock {
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint blockTimestmap, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiresAt);
    error TxFailedError();

    event Queue(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Execute(
        bytes32 indexed txId,
        address indexed target,
        uint value,
        string func,
        bytes data,
        uint timestamp
    );
    event Cancel(bytes32 indexed txId);

    uint public constant MIN_DELAY = 10; 
    uint public constant MAX_DELAY = 1000; 
    uint public constant GRACE_PERIOD = 1000; 

    address public owner;
    // tx id => queued (в очереди)
    mapping(bytes32 => bool) public queued;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwnerError();
        }
        _;
    }

    receive() external payable {}

    function getTxId(address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp)
     public pure returns (bytes32) {
        return keccak256(abi.encode(_target, _value, _func, _data, _timestamp));
    }

    //>>>>>>>>>Set tx to queue
    function queue( address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp)
     external onlyOwner returns (bytes32 txId) {
        txId = getTxId(_target, _value, _func, _data, _timestamp); //get hash of tx (keccak)
        if (queued[txId]) {
            revert AlreadyQueuedError(txId);
        }
        if (
            _timestamp < block.timestamp + MIN_DELAY ||
            _timestamp > block.timestamp + MAX_DELAY
        ) {
            revert TimestampNotInRangeError(block.timestamp, _timestamp); //or u can apply requere modifier
        }

        queued[txId] = true;

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    function execute( address _target, uint _value, string calldata _func, bytes calldata _data, uint _timestamp) 
    external payable onlyOwner returns (bytes memory) {

        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        if (!queued[txId]) {
            revert NotQueuedError(txId);}
        // ----|-------------------|-------
        //  timestamp    timestamp + grace period
        if (block.timestamp < _timestamp) {
            revert TimestampNotPassedError(block.timestamp, _timestamp);
        }
        if (block.timestamp > _timestamp + GRACE_PERIOD) {
            revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
        }
        queued[txId] = false;
        // prepare data
        bytes memory data;
        if (bytes(_func).length > 0) {
            // data = func selector + _data
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            // call fallback with data
            data = _data;
        }
        // call target
        (bool ok, bytes memory res) = _target.call{value: _value}(data);
        if (!ok) {
            revert TxFailedError();
        }
        emit Execute(txId, _target, _value, _func, _data, _timestamp);
        return res;
    }

    function cancel(bytes32 _txId) external onlyOwner {
        if (!queued[_txId]) {
            revert NotQueuedError(_txId);
        }

        queued[_txId] = false;

        emit Cancel(_txId);
    }
}

//Testing TimeLOck
contract Runner{
    address public lock;
    string public message;
    mapping(address => uint) public payments;

    constructor(address _lock){
        lock = _lock;
    }

    function run(string memory newMsg) external payable{
        require(msg.sender == lock, "Invalid address");

        payments[msg.sender] += msg.value;
        message = newMsg;
    }
    function newTimeStamp() external view returns(uint){
        return block.timestamp + 100;
    }
    function prepareData(string calldata _msg) external pure returns(bytes memory){
        return abi.encode(_msg);
    }
}