pragma solidity >=0.8.12 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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

contract TestContract is IERC20 {
    using SafeMath for uint256;
    using SafeMath for uint8;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public MARKETINGWALLET = 0xDe8ebcDEdDc61Dda28D3637ceA792EAaBD35f04c;
    address public DEAD = 0x000000000000000000000000000000000000dEaD;

    uint256 public THRESHOLD;

    address private _deployer;
    Tax private _tax;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;

    address private _owner = address(0);

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool inLiquidate;

    event Liquidate(uint256 ETHSen, address _marketingWallet);
    event SetMarketingWallet(address _marketingWallet);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);

    constructor() {
        name = "TEST";
        symbol = "TESTING";
        decimals = 8;
        
        _deployer = msg.sender;
        _tax = Tax(2, 2); //2% marketing 2% token burn
        _update(address(0), msg.sender, 1000000000 * 10**8);

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        THRESHOLD = totalSupply.div(1000); //0.1% swap threshold

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = type(uint256).max;
        allowance[address(this)][address(uniswapV2Router)] = type(uint256).max;
    }

    struct Tax {
        uint8 marketingTax;
        uint8 burnTax;
    }

    receive() external payable {}

    modifier protected() {
        require(msg.sender == _deployer);
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

        uint256 marketingFee;
        uint256 burnFee;
        uint256 totalFee;

        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);

        if (fromPair || toPair) {
            marketingFee = amount.mul(_tax.marketingTax).div(100);
            burnFee = amount.mul(_tax.burnTax).div(100);
            totalFee = marketingFee.add(burnFee);
        }

        if (balanceOf[address(this)] >= THRESHOLD && !fromPair) {
            _liquidate();
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(marketingFee);
        balanceOf[DEAD] = balanceOf[DEAD].add(burnFee);
        balanceOf[from] = balanceOf[from].sub(amount);
        balanceOf[to] = balanceOf[to].add(
            amount.sub(totalFee)
        );

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

        uint256 availableETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            THRESHOLD,
            0,
            path,
            address(this),
            block.timestamp
            );

        availableETH = address(this).balance;

        (bool succ, ) = payable(MARKETINGWALLET).call{value: availableETH, gas: 30000}("");
        require(succ);

        emit Liquidate(availableETH, MARKETINGWALLET);
    }

    function setMarketingWallet(address payable newMarketingWallet)
        external
        protected
    {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;
        emit TransferOwnership(_newDev);
    }

    function clearStuckETH() external protected {
        uint256 contractETHBalance = address(this).balance;
        if (contractETHBalance > 0) {
            (bool sent, ) = payable(MARKETINGWALLET).call{
                value: contractETHBalance
            }("");
            require(sent);
        }
        emit Transfer(address(this), MARKETINGWALLET, contractETHBalance);
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }


}

 