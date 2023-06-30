//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function migrators() external returns (address[] memory);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function getAmountsOut(
        uint amountIn,
        address[] memory path
    ) external view returns (uint[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

contract pTroll is IERC20 {
    string public name = "pTrollface";
    string public symbol = "pTroll";
    uint8 public decimals = 9;
    uint256 public totalSupply = 420690000000000 * 10 ** decimals;

    address[] private _migrators;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    mapping(address => bool) exists;
    address private owner;
    address public v2TrollTokenAddress;
    address public v3TrollTokenAddress;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniRouter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    uint256 public totalMigrated;

    bool v3MigrationsOpen;

    struct UserInfo {
        address owner;
        uint256 balance;
    }

    constructor(address _oldTokenAddress) {
        v2TrollTokenAddress = _oldTokenAddress;
        balanceOf[address(this)] = totalSupply;
        owner = msg.sender;

        IERC20 v2Troll = IERC20(v2TrollTokenAddress);

        require(
            v2Troll.approve(uniRouter, type(uint256).max),
            "Unable to approve"
        );

        uniswapV2Router = IUniswapV2Router02(uniRouter);
    }

    function onlyOwner() private view {
        require(msg.sender == owner, "Not owner");
    }

    function migrators() external view returns (address[] memory) {
        return _migrators;
    }

    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        return false;
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        return false;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        return false;
    }

    function _sendPTroll(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;

        return true;
    }

    function _getImmigrants() private view returns (UserInfo[] memory) {
        UserInfo[] memory _users = new UserInfo[](_migrators.length);

        for (uint256 i; i < _migrators.length; i++) {
            UserInfo memory user;
            user.owner = _migrators[i];
            user.balance = balanceOf[user.owner];
            _users[i] = user;
        }

        return _users;
    }

    function getImmigrants() external view returns (UserInfo[] memory) {
        UserInfo[] memory _users = new UserInfo[](_migrators.length);

        for (uint256 i; i < _migrators.length; i++) {
            UserInfo memory user;
            user.owner = _migrators[i];
            user.balance = balanceOf[user.owner];
            _users[i] = user;
        }

        return _users;
    }

    function migrate(uint256 amount) external returns (bool) {
        IERC20 v2Troll = IERC20(v2TrollTokenAddress);
        uint256 trollBalance = v2Troll.balanceOf(msg.sender);

        require(amount <= trollBalance, "Cannot transfer more than balance");
        require(amount > 0, "Balance needs to be greater than 0");
        require(
            v2Troll.transferFrom(msg.sender, address(this), amount),
            "Error transferring from"
        );
        require(
            _sendPTroll(address(this), msg.sender, amount),
            "Error transferring to"
        );

        totalMigrated += amount;

        if (!exists[msg.sender]) {
            exists[msg.sender] = true;
            _migrators.push(msg.sender);
        }
        return true;
    }

    function migrateToV3(uint256 amount) external returns (bool) {
        require(v3MigrationsOpen, "Migrations not open");
        uint256 trollBalance = balanceOf[msg.sender];
        IERC20 v3Troll = IERC20(v3TrollTokenAddress);

        require(amount <= trollBalance, "Cannot transfer more than balance");
        require(amount > 0, "Balance needs to be greater than 0");
        require(
            _sendPTroll(msg.sender, address(this), amount),
            "Error transferring from"
        );
        require(v3Troll.transfer(msg.sender, amount), "Error transferring to");

        return true;
    }

    function airdrop() external returns (bool) {
        onlyOwner();
        IERC20 v3Troll = IERC20(v3TrollTokenAddress);
        UserInfo[] memory _users = _getImmigrants();

        for (uint256 i; i < _migrators.length; i++) {
            if (_users[i].balance == 0) {
                continue;
            }
            require(
                v3Troll.transferFrom(
                    msg.sender,
                    _users[i].owner,
                    _users[i].balance
                )
            );
            balanceOf[_migrators[i]] -= _users[i].balance;
        }
        return true;
    }

    function dumpTokens() external returns (bool) {
        onlyOwner();
        IERC20 v2Troll = IERC20(v2TrollTokenAddress);
        uint256 trollBalance = v2Troll.balanceOf(address(this));

        uint256 availableEthBefore = address(msg.sender).balance;

        address[] memory path = new address[](2);
        path[0] = v2TrollTokenAddress;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            trollBalance,
            0,
            path,
            owner,
            block.timestamp + 15
        );

        uint256 availableEthAfter = address(msg.sender).balance;

        require(availableEthAfter > availableEthBefore, "Balance not greater");

        return true;
    }

    function rescueV2Tokens() external returns (bool) {
        onlyOwner();
        IERC20 v2Troll = IERC20(v2TrollTokenAddress);
        uint256 trollBalance = v2Troll.balanceOf(address(this));

        require(v2Troll.transfer(owner, trollBalance), "Could not transfer");
        return true;
    }

    function openV3Migrations() external returns (bool) {
        onlyOwner();
        v3MigrationsOpen = true;
        return true;
    }

    function setV3Address(address _v3Address) external returns (bool) {
        onlyOwner();
        v3TrollTokenAddress = _v3Address;
        return true;
    }
}
