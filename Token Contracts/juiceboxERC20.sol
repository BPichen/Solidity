//SPDX-License-Identifier: MIT

pragma solidity >=0.8.12 <0.9.0;

interface IJBToken {
    function projectId() external view returns (uint256);
    function decimals() external view returns (uint8);
    function totalSupply(uint256 _projectId) external view returns (uint256);
    function balanceOf(address _account, uint256 _projectId) external view returns (uint256);
    function mint(uint256 _projectId, address _account, uint256 _amount) external;
    function burn(uint256 _projectId, address _account, uint256 _amount) external;
    function approve(uint256, address _spender, uint256 _amount) external;
    function transfer(uint256 _projectId, address _to, uint256 _amount) external;
    function transferFrom(uint256 _projectId, address _from, address _to, uint256 _amount) external;
}

contract JuiceboxToken is IJBToken {

    uint256 public projectId;
    uint8 public constant decimals = 18;
    uint256 private _totalSupply = 1000000000 * 10 ** decimals;
    string public name = "Test";
    string public symbol = "TEST";

    address private _deployer;

    mapping(address => uint256) private _balanceOf;
    mapping(address => bool) private _isAuthorized;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address private jb = 0x1246a50e3aDaF684Ac566f0c40816fF738F309B3;//Testnet JBTokenStore address

    bool private _launchReady;
    bool private _tradingOpen;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ReadyLaunch(address indexed from);
    event OpenTrading(address indexed from);
    event SetAuthorize(address indexed from, address authorizee, bool _authorized);
    
    constructor(uint256 _projectId) {
        projectId = _projectId;    

        _isAuthorized[msg.sender] = true;
        _deployer = msg.sender;

        _balanceOf[address(this)] = _totalSupply;

    }

    receive() external payable {}

    //IJBToken functions

    function totalSupply(uint256 _projectId) external view returns (uint256) {
         require(_projectId == projectId);
         return _totalSupply;
    }

    function balanceOf(address _account, uint256 _projectId) external override view returns (uint256) {
         require(_projectId == projectId);
         return _balanceOf[_account];
    }

    function mint(uint256 _projectId, address _account, uint256 _amount) external override {
        require(_projectId == projectId && msg.sender == jb);
        _update(address(this), _account, _amount);
    }

    function burn(uint256 _projectId, address _account, uint256 _amount) external override {
        require(_projectId == projectId && msg.sender == jb);
        _update(_account, address(0), _amount);
    }

    function approve(uint256 _projectId, address _spender, uint256 _amount) external override {
        require(_projectId == projectId);
        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
    }

    function transfer(uint256 _projectId, address _to, uint256 _amount) external override {
         require(_projectId == projectId);
         _transferFrom(msg.sender, _to, _amount);
    }

    function transferFrom(uint256 _projectId, address _from, address _to, uint256 _amount) external override {
         require(_projectId == projectId);
         allowance[_from][msg.sender] -= _amount;
         _transferFrom(_from, _to, _amount);
    }

    //ERC20 functions

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return _balanceOf[_account];
    }

    function transfer(address _to, uint256 _amount) external returns (bool) {
        return _transferFrom(msg.sender, _to, _amount);
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        allowance[_from][msg.sender] -= _amount;
        return _transferFrom(_from, _to, _amount);
    }

    function _transferFrom(address _from, address _to, uint256 _amount) private returns (bool) {

        if(_isAuthorized[_from] || _isAuthorized[_to]) {
            return(_update(_from, _to, _amount));
        }
            
        require(_tradingOpen);
        
        _balanceOf[_from] -= _amount;
        _balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }

    function _update(address _from, address _to, uint256 _amount) private returns (bool) {

        _balanceOf[_from] -= _amount;
        _balanceOf[_to] += _amount;

        emit Transfer(_from, _to, _amount);
        return true;
    }
    
    function readyLaunch() external {
        require(_isAuthorized[msg.sender] && !_launchReady);
        _update(address(this), msg.sender, _balanceOf[address(this)]);

        _launchReady = true;

        emit ReadyLaunch(msg.sender);
    }

    function openTrading() external {
        require(_isAuthorized[msg.sender] && _launchReady && !_tradingOpen);

        _tradingOpen = true;

        emit OpenTrading(msg.sender);
    }

    function setAuthorize(address _authorizee, bool _authorized) external {
        require(msg.sender == _deployer || _isAuthorized[msg.sender]);
        _isAuthorized[_authorizee] = _authorized;

        emit SetAuthorize(msg.sender, _authorizee, _authorized);
    }
    
}