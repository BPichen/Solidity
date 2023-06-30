//SPDX-License-Identifier: MIT

pragma solidity 0.8.12;

import "./SafeMath.sol";

interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

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
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract TestErc20 is IERC20 {
    using SafeMath for uint256;
    using SafeMath for uint8;

    string public name = "Trollface";
    string public symbol = "TROLL";
    uint8 public decimals = 9;
    uint256 public totalSupply;

    address public MARKETINGWALLET = 0xd53d425AdccA8350133Fd2476C8BB8cf2294b305;
    address private dead = 0x000000000000000000000000000000000000dEaD;

    address private oldTokenAddress = 0xabC21d9D0cbf329E6aaeeC434bDBDab1C8004D5a;

    uint256 public THRESHOLD;

    uint8 marketingTax = 1; //1% marketing

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;

    address private _owner;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inLiquidate;
    bool tradingOpen;
    bool migrationOpen;

    event Liquidate(uint256 ethForMarketing);
    event SetMarketingWallet(address _marketingWallet);
    event SetAutoLpReceiverWallet(address newAutoLpReceiverWallet);
    event TransferOwnership(address _newOwner);
    event SetExempt(address _address, bool _isExempt);
    event AddPair(address _pair);
    event Migrate(address receiver, uint256 tokensSent);
    event LaunchReady();
    event OpenTrading(bool tradingOpen);

    constructor() {
        _owner = msg.sender;
        _update(address(0), msg.sender, 420690000000000 * 10**9);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        THRESHOLD = totalSupply.div(10**3); //0.1% swap threshold (too high?)

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = type(uint256).max;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;

        migrationOpen = true;
    }

    receive() external payable {}

    modifier protected() {
        require(msg.sender == _owner);
        _;
    }

    modifier lockLiquidate() {
        inLiquidate = true;
        _;
        inLiquidate = false;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        uint256 availableAllowance = allowance[from][msg.sender];
        if (availableAllowance < type(uint256).max) {
            allowance[from][msg.sender] = availableAllowance.sub(amount);
        }

        return _transferFrom(from, to, amount);
    }

    function _transferFrom(address from, address to, uint256 amount) private returns (bool) {

        if (inLiquidate || isExempt[from] || isExempt[to]) {
            return _update(from, to, amount);
        }

        require(tradingOpen);

        uint256 marketingFee;

        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);

        if (fromPair || toPair) {
            marketingFee = amount.mul(marketingTax).div(100);
        }

        if (balanceOf[address(this)] >= THRESHOLD && !fromPair) {
            _liquidate();
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(marketingFee);
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(amount.sub(marketingFee));

        emit Transfer(from, to, amount);
        return true;
    }

    function _update(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (from != address(0)) {
            balanceOf[from] = balanceOf[from].sub(amount);
        } else {
            totalSupply = totalSupply.add(amount);
        }
        if (to == address(0)) {
            totalSupply = totalSupply.sub(amount);
        } else {
            balanceOf[to] = balanceOf[to].add(amount);
        }
        emit Transfer(from, to, amount);
        return true;
    }

    function _liquidate() private lockLiquidate {
  
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            THRESHOLD,
            0,
            path,
            address(this),
            block.timestamp
            );

        uint256 ethForMarketing = address(this).balance;

        (bool succ, ) = payable(MARKETINGWALLET).call{value: ethForMarketing, gas: 30000}("");
        require(succ);

        emit Liquidate(ethForMarketing);
    }


    function setMarketingWallet(address payable newMarketingWallet) external protected {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function transferOwnership(address _newOwner) external protected {
        isExempt[_owner] = false;
        _owner = _newOwner;
        isExempt[_newOwner] = true;
        emit TransferOwnership(_newOwner);
    }

    function clearStuckETH() external protected {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            (bool sent, ) = payable(MARKETINGWALLET).call{
                value: contractETHBalance
            }("");
            require(sent);
        }
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit SetExempt(_address, _isExempt);
    }

    function addPair(address _address) external protected {
        require(isPair[_address] = false);
        isPair[_address] = true;
        emit AddPair(_address);
    }

    function migrate() external {
        require(migrationOpen);    
        IERC20 oldToken = IERC20(oldTokenAddress);

        uint256 tokensSent = oldToken.balanceOf(msg.sender);

        require(tokensSent > 0);
        require(oldToken.transferFrom(msg.sender, _owner, tokensSent));

        require(_update(address(this), msg.sender, tokensSent));
        emit Migrate(msg.sender, tokensSent);
    }

    function readyLaunch() external protected {
        require(migrationOpen == true);
        migrationOpen = false;
        _update(address(this), _owner, balanceOf[address(this)]);

        emit LaunchReady();
    }

    function openTrading() external protected {
        tradingOpen = true;
        emit OpenTrading(tradingOpen);
    }


}

