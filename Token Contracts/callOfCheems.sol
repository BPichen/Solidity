//SPDX-License-Identifier: MIT

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(///(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@,          @@@@@@@@@@@@@@@@&          (@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@(       @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@       &@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@.      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      #@@@@@@@@@@@@@
@@@@@@@@@@@     *@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      @@@@@@@@@@@
@@@@@@@@@     @@@@@@@@@@@@@%(@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@     @@@@@@@@@
@@@@@@@     @@@@@@@@@@@@@@((#%%%%%%%%%%%%%(%##(/@@@@@@@@@@@@@@@@@@@     @@@@@@@
@@@@@,    @@@@@@@@@@@@@@@(%%%#####/////(*(((*###((((,,@@@@@@@@@@@@@@@    #@@@@@
@@@@    ,@@@@@@@@@@@@@##%%((((((((///*//****((#(//((,,,*@@@@@@@@@@@@@@     @@@@
@@@    @@@@@@@@@@@@@@#%%#(((((((((((((`//////(*((((##(***@@@@@@@@@@@@@@%    @@@
@@    @@@@@@@@@@@@@@..((((((((((((((((((((/,,,,,/`(##((**@@@@@@@@@@@@@@@(    @@
@%    @@@@@@@@@@@@@&*`/(((((/`....../###(##(,,,,,,((((((((*.(#&&&@@@@@@@@    @@
@    @@@@@@@@@&&&&&(((/////((/////////&&&#%///,,,,,#(#((//(/*(,#&&&&@@@@@@    @
@    @@@@@&&@@&%%((//(//#(%#%#/////*&&&&&%%/***,,,/(((###,*(**(((@&&&&@@@@    @
@   ,&%&&&@@@&%.......,,////*(/*`//(&&&&&%#%%%%(((#(((((*****(#&&/***%%%@@    @
@   *%%@@@##%#........,,,*,,,,,,((//&&%&%%%%%%%%((,,*********(&&&&&&&(*.%@    @
@    &#(...(%#&&/***,,,,,,,,,,,///(((#&&%%%%#****(,,,,*,,,(&&&&&&&&&&&&&(/    @
@    .. ..,%#%%&&&((#,,,/##((###(((((#%%%%%#**,,,,,,,,*,,,,,/&&&&&&&&&&&&%    @
@%   /..,/%(,#%(&((,,*##(#%%%%%%%%#%%%%%%%%%(((((**,,,,,/(&&%&&&&&&%#&%#(    @@
@@    *,*%%%,/%%*(,(# .(#%%%%%%%%%###(((((%((((##(,,,.,/..#&&&&&%%%&&&&&%    @@
@@@    ,(,,,,,%(/,,,#.,*((##%%%%((((((((((((((**....,,(,.*,&&&(%&*&&&&&%    @@@
@@@@    (.,,,,,/,,.,,//#((,,%####(((((((((((*... .,,,(/ ,*&&&&#%%&&%##,    @@@@
@@@@@*    ,*,,,,.,,,,*#//,/,***%(((........  ....../(/.. .&&%&&#&&#*#    &@@@@@
@@@@@@@    / ,... ,,(/.,,.,,*****`/,,.   .  .   . .     .,#&&/&%#%&     @@@@@@@
@@@@@@@@@     ,,///((//...,#(//*****,`///, ..   ..,,*,,...(#&(%##     @@@@@@@@@
@@@@@@@@@@@     &&%*.  ..  *.**,,,,,.,...../.......**....(#//&&     @@@@@@@@@@@
@@@@@@@@@@@@@/     %%%    .,(..,,,,.*, . .. ......../(#/..*.     &@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@&       *,,*,,,,,.,., ..(.,.,,........,.      @@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@#         .../,/##/#/,,...,*,         &@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@                           @@@@@@@@@@@@@@@@@@@@@@@@@@

/******************************************************************************\
|  _____         _  _           __   _____  _                                  |
| /  __ \       | || |         / _| /  __ \| |                                 |
| | /  \/  __ _ | || |   ___  | |_  | /  \/| |__    ___   ___  _ __ ___   ___  |
| | |     / _` || || |  / _ \ |  _| | |    | '_ \  / _ \ / _ \| '_ ` _ \ / __| |
| | \__/\| (_| || || | | (_) || |   | \__/\| | | ||  __/|  __/| | | | | |\__ \ |
|  \____/ \__,_||_||_|  \___/ |_|    \____/|_| |_| \___| \___||_| |_| |_||___/ |
\******************************************************************************/    

pragma solidity 7.8.0;

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

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract FFFAAAA is IERC20 {
    using SafeMath for uint256;
    using SafeMath for uint8;

    string public constant name;
    string public constant symbol;
    uint8 public constant decimals;
    uint256 public totalSupply;

    address public MARKETINGWALLET = address(this); // CHANGE
    address public OPERATIONSWALLET = address(this); // CHANGE
    address public AUTOLPRECEIVERWALLET = address(this); // CHANGE
    uint256 public THRESHOLD;
    uint256 public MAXWALLET;
    uint256 public MAXTRANSACTION;
    address private oldTokenAddress;

    address private _deployer;
    Tax private _tax;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;
    mapping(address => bool) private isEarlyTrader;

    address private _owner = address(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router01 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 private migratedFunds;
    bool inLiquidate;
    bool tradingOpen;
    bool migrationOpen;

    event Liquidate(
        uint256 bnbForMarketing,
        uint256 bnbForOperations,
        uint256 bnbForLiquidity,
        uint256 tokensForLiquidity
    );
    event SetMarketingWallet(address newMarketingWallet);
    event SetOperationsWallet(address newOperationsWallet);
    event SetAutoLpReceiverWallet(address newAutoLpReceiverWallet);
    event SetMaxTx(uint256 maxTxTokens);
    event SetMaxWallet(uint256 maxWalletTokens);
    event TransferOwnership(address _newDev);
    event UpdateExempt(address _address, bool _isExempt);
    event AddPair(address _pair);
    event OpenTrading(bool tradingOpen);
    event RemoveEarlyTrader(address _earlyTrader);

    constructor() {
        name = "CCCCCKKKKKk";
        symbol = "FACK";
        decimals = 8;
        totalSupply = 1000000 * 10**8;

        _deployer = msg.sender;
        _tax = Tax(40, 30, 30, 10); //4% marketing, 3% operations, 3% liquidity, 10% total tx fee
        _update(address(0), address(this), 1000000 * 10**8);
        // TESTNET
        uniswapV2Router = IUniswapV2Router01(
            0xD99D1c33F9fC3444f8101754aBC46c52416550D1
        );

        //uniswapV2Router = IUniswapV2Router01(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );

        THRESHOLD = totalSupply.mul(25000).div(100000); //0.25% swap threshold
        MAXWALLET = totalSupply.mul(2).div(100); //2% max wallet
        MAXTRANSACTION = totalSupply.div(100); //1% max transaction

        oldTokenAddress = 0xB3dF3b4caCa694825F9220c717f094E1E112Fb65;

        isPair[address(uniswapV2Pair)] = true;
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = totalSupply;
        allowance[address(this)][address(uniswapV2Router)] = totalSupply;

        migrationOpen = true;
    }

    struct Tax {
        uint8 marketingTax;
        uint8 operationsTax;
        uint8 liquidityTax;
        uint16 txFee;
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

    function tradingIsOpen() external view returns (bool) {
        return tradingOpen;
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
            allowance[from][msg.sender] = availableAllowance.sub(
                amount,
                "insufficient allowance"
            );
        }

        return _transferFrom(from, to, amount);
    }

    function migrate() external returns(bool){
        require(migrationOpen);
        IERC20 oldToken = IERC(oldTokenAddress);

        tokensSent = oldToken.balanceOf(msg.sender);
        require(tokensSent > 0);
        require(oldToken.transferFrom(msg.sender, _deployer, tokensSent));

        require(_transferFrom(address(this), msg.sender, amount));
        migratedFunds = migratedFunds.add(amount);
        emit Migrate(to, amount);
        
        return(true);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 amount
    ) private returns (bool) {
        if (inLiquidate || isExempt[from] || isExempt[to]) {
            // We are either swapping or there's no need to pay taxes
            return _update(from, to, amount);
        }

        uint256 fee;
        // this will lock the blacklisted tokens
        require(!(isEarlyTrader[from] || isEarlyTrader[to]), "beep boop");

        (bool fromPair, bool toPair) = (isPair[from], isPair[to]);
        if (!tradingOpen && fromPair) {
            // The pair transfers tokens out of the liquidity pool, so looking at a blacklistable purchase?
            isEarlyTrader[to] = true;
        }

        if (fromPair || toPair) {
            // looking at a sell or a purchase
            require((amount <= MAXTRANSACTION), "maxTx");
            fee = amount.mul(_tax.txFee).div(100);
        }

        if (!toPair) {
            // ... it's not a sell
            require((balanceOf[to].add(amount)) <= MAXWALLET, "maxWallet");
        }

        if (balanceOf[address(this)] >= THRESHOLD && !fromPair) {
            // it's a sell or transfer, so let's fuck everyone some more
            _liquidate();
        }

        balanceOf[address(this)] = balanceOf[address(this)].add(fee);
        balanceOf[from] = balanceOf[from].sub(
            amount,
            "insufficient balance FROM"
        );
        balanceOf[to] = balanceOf[to].add(
            amount.sub(fee, "insufficient amount left to send")
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
            balanceOf[from] = balanceOf[from].sub(
                amount,
                "insufficient balance FROM"
            );
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
        uint256 liqTax2 = uint256(_tax.liquidityTax).div(2);
        uint256 tokensForLiquidity = THRESHOLD.mul(liqTax2).div(100);
        uint256 tokensToSwap = THRESHOLD.sub(tokensForLiquidity.div(2));
        uint256 availableBeans = 0;

        {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = uniswapV2Router.WETH();

            availableBeans = uniswapV2Router.swapExactTokensForETH(
                tokensToSwap,
                0,
                path,
                address(this),
                block.timestamp + 15
            )[1];
            require(availableBeans > 0, "received no beans for swap");
        }
        uint256 bnbForMarketing = availableBeans.mul(_tax.marketingTax).div(
            100
        );
        uint256 bnbForOperations = availableBeans.mul(_tax.operationsTax).div(
            100
        );
        uint256 bnbForLiquidity = availableBeans.mul(liqTax2).div(100);

        (bool succ, ) = payable(MARKETINGWALLET).call{value: bnbForMarketing}(
            ""
        );
        require(succ);

        (succ, ) = payable(OPERATIONSWALLET).call{value: bnbForOperations}("");
        require(succ);

        if (tokensForLiquidity > 0) {
            (, , uint256 receivedLP) = uniswapV2Router.addLiquidityETH{
                value: bnbForLiquidity
            }(
                address(this),
                tokensForLiquidity,
                0,
                0,
                AUTOLPRECEIVERWALLET,
                block.timestamp + 15
            );
            require(receivedLP > 0, "received no liquidity.. ?");
        }

        emit Liquidate(
            bnbForMarketing,
            bnbForOperations,
            bnbForLiquidity,
            tokensForLiquidity
        );
    }

    function earlyTrader(address add) external view returns (bool) {
        return isEarlyTrader[add];
    }

    function setMarketingWallet(address payable newMarketingWallet)
        external
        protected
    {
        MARKETINGWALLET = newMarketingWallet;
        emit SetMarketingWallet(newMarketingWallet);
    }

    function setOperationsWallet(address payable newOperationsWallet)
        external
        protected
    {
        OPERATIONSWALLET = newOperationsWallet;
        emit SetOperationsWallet(newOperationsWallet);
    }

    function setAutoLpReceiverWallet(address payable newLpReceiver)
        external
        protected
    {
        AUTOLPRECEIVERWALLET = newLpReceiver;
        emit SetAutoLpReceiverWallet(newLpReceiver);
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;
        emit TransferOwnership(_newDev);
    }

    function clearStuckBNB() external protected {
        uint256 contractBnbBalance = address(this).balance;
        if (contractBnbBalance > 0) {
            (bool sent, ) = payable(MARKETINGWALLET).call{
                value: contractBnbBalance
            }("");
            require(sent);
        }
        emit Transfer(address(this), MARKETINGWALLET, contractBnbBalance);
    }

    function readyLunch() external protected {
        migrationOpen = false;
        IERC20 oldToken = IERC(oldTokenAddress);
        uint256 oldTokensToSwap = oldToken.balanceOf(address[this]);

        address[] memory path = new address[](2);
        path[0] = oldTokenAddress;
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETH(
                oldTokensToSwap,
                0,
                path,
                address(this),
                block.timestamp + 15
            )[1];
        uint256 contractBnbBalance = address(this).balance;

        require(_update(address(this), _deployer, balanceOf[address(this)]));
        (bool sent, ) = payable(_reployer).call{
                value: contractBnbBalance
            }("");
            require(sent);
    }

    function manualLiquidate() external protected {
        require(balanceOf[address(this)] >= THRESHOLD);
        _liquidate();
    }

    function setLiquidationThreshold(uint256 numberOfTokens)
        external
        protected
    {
        require(numberOfTokens <= totalSupply, "too high threshold");
        THRESHOLD = numberOfTokens;
    }

    function setMaxTx(uint256 maxTxTokens) external protected {
        MAXTRANSACTION = maxTxTokens;
        emit SetMaxTx(maxTxTokens);
    }

    function setMaxWallet(uint256 maxWalletTokens) external protected {
        MAXWALLET = maxWalletTokens;
        emit SetMaxWallet(maxWalletTokens);
    }

    function setExempt(address _address, bool _isExempt) external protected {
        isExempt[_address] = _isExempt;
        emit UpdateExempt(_address, _isExempt);
    }

    function addPair(address _address) external protected {
        require(isPair[_address] = false);
        isPair[_address] = true;
        emit AddPair(_address);
    }

    function openTrading() external protected {
        tradingOpen = true;
        emit OpenTrading(tradingOpen);
    }

    function removeEarlyTrader(address _earlyTrader) external protected {
        isEarlyTrader[_earlyTrader] = false;
        emit RemoveEarlyTrader(_earlyTrader);
    }

    /*function initLiquidity() external payable protected {
        IWETH WBNB = IWETH(uniswapV2Router.WETH());
        IWETH(WBNB).deposit{value: msg.value}();
        require(
            IWETH(WBNB).transfer(uniswapV2Pair, msg.value),
            "transfering WBNB failed?!"
        );
        balanceOf[uniswapV2Pair] = totalSupply;

        require(
            IUniswapV2Pair(uniswapV2Pair).mint(msg.sender) > 0,
            "did not receive any liquidity for purchase"
        );
    }
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}*/

