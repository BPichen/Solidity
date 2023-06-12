//SPDX-License-Identifier: MIT

/*(((((((////(((((((((####%%%##%%%%&&&&&&&@@@@@@@&&&&&&&&%%%%#%%#####((((((((/////((((((((
/^^((((((((/////////(((%%%%&&&@#((((%@&&&&&&&&%&&&&&&@%((((#@&&&%%%%(((/////////((((((((^^
/^^^^((((((((///(((##%%&&#((%&&&&%%%%%%%%#%  ##  (     %%%&&&&%((#&&%%##((////(((((((/^^^^
/^^^^^//((((###(#%%&@((%&&&&&%%#         *%  %%% %%%% .####%%%&&&&&%((@&%##(##(((((//^^^^^
/^^///////(##%%&&#((&&%%%#     *%%%%%%%%%%%, #%%%%%    .##%%%%%%##%%%&&((%&&%%##(//////^^^
((//////((##%&&(#&&%%##   %%%%%%%%%%%%%%%%%%%%%%%%%%%%  #%%%%%%#######%%&&#(@&%#((//////((
((((((((##%&((@&&%%%%#  %%%%%%%%%%%%%%%%%%%%%%%%%%   %%%%%%%%#########%%%%&&@((&%##(/(((((
((((##%%&&((&&%###%%%        %%%%%%%%%%%(      %%%%   %%&&%%%%%#####%%%%%###%&&((&&%###(((
#((##%&&((&&%#####  @@@    @@  %%%%%%  %@@.  .@  (%   %&&&&%%%%%%#%%%%########%&&(#&%%##((
/(#%%&@(@&&%%%%##. .@    &@@(  %%%%%#   &    @@@ ,%   (&&%%%%%%%%%%%#######%%%%%&&@(@&%##(
((#%&#(&&&%%%%%%%%.     .%%%%%%%%%%%%%   ,      %%%   /&&&%%%%&&&%%%%%##%%%%%%%%%%&&(#%%#(
(#%&((&%%##%%%%%%%%     *((((,.((((/    %%%%%%%%%%%   &&&&&&&&&%%%%%%%%%%%%%%%%###%%&((%%#
#%&((&%%########%%  ((((((((((((((((((((  %%%%%%%%,         %%%%%    %%%%%%########%%&((%%
%&#(&&%######        *((((((((((((((((   %%%%%%%%%    /%%%%%%%%%%%%%,  %%###########%&&(%&
&@(@&&%%%%   (((((((((((((((((((((  %%%%%%%%%%%%%%   %%%%%%%%%%%%%@@@.  %%##%%%%%%%%%%&@(&
&((&%%%%%%.    .     ,(((((((((/ .%%%%%%%%%%%%%%%%   %%%%%%%%%%%(         .%%%%%%%%%%%%&(#
&(&&%##########,  (((((((/,   (%%%%%%%%%%%%%%%%%%%/      *%%%%%%%%%%@@@@%%   #########%%&(
@(&%%##########%%  (%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     (%%%%@@@@%@%#   #######%%&(
@(&&%%%%%%%%%%%%%.  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   %%%%%%%%%%,  #%%%%%%%&&(
@(@&%%%%%%% @@@@@@@  @@@.@@@@  @@@@@,  @@@ @@@ ((((((*  ((( (((/((((((( ((((((( %%%%%%%&&(
&(&&%###### @@@@@@@@ @@@,@@@@ @@@.@@@  @@@ @@@ (((((((/ ((( (((/((((((( ((((((( ######%%&(
&((&%%##### @@@@ @@@ @@@*@@@@ @@@ @@@@ @@@(@@# (((( ((( ((( (((/  ((((    (((   #####%%&(#
%@(@&&%%%%% @@@@ @@@ @@@*@@@@ @@@ @@@@ @@@@@@  /((( ((( ((( (((/  ((((    (((   %%%%%%&@(&
%&#(&&%%%%% @@@@ @@@ @@@/@@@@ @@@      @@@@@@  /((((((  ((( (((/  ((((    (((   %%%%%&&(%&
%%&((&%%### @@@@ @@@ @@@/@@@@ @@@      @@@@@@  /((( ((( ((( (((/  ((((    (((   ###%%&(#&%
(#%&((&%%## &@@@ @@@ @@@#@@@@ @@@ @@@@ @@@(@@@ /((( ((( ((( ((((  ((((    (((   ##%%&((&%#
((#%&#(&&&% &@@@%@@@ @@@&@@@@ @@@ @@@% @@@ @@@ /((( ((( (((.(((/  ((((    (((   %&&&(%&%#(
//##%&@(%&& %@@@@@@@  @@@@@@   @@@@@@  @@@ @@@&*(((((((  ((((((   ((((    (((   &&%(@&%##/
(((##%&&((@*                                                                   ,@(#&%%##((
((((###%&&((&&%%##%%%%%#######%%%%%%%%%%%%%&&&&&%%%%%%%%%%%%%#######%%%%%##%%&&((&&%###(((
((((((/(##%&((@&&%%%%########%%%%%%%%%%%%%%&&&&%%%%%%%%%%%%%%#########%%%&&&@((&%##(/(((((
((///////((#%&@((@&%%#######%%%%%########%%%%%%%%#%######%%%%%%#######%%&@((@&%#((///////(
/^^^//////(##%%&&%((@&&%%##%%%%%##########%%%%%%%#########%%%%%%##%%&&@((@&&%%##(//////^^^
/^^^^^^/(((((##(##%&@(((@&&&&%%%##########%%%%%%%##########%%%&&&&@(((&&%##(##(((((//^^^^^
/^^^^((((((((////((##%%&&#(((@&&&%%%%%%%%%%%%%%%%%%%%%%%%%&&&@(((%&&%%##((////(((((((/^^^^
/^^((((((((^/////////((%%%%&&&@%(((((%@&&&&&&&&&&&&&@%(((((%&&&&%%%#((//////////((((((((*/ 

pragma solidity >=0.8.12 <0.9.0;

interface IERC20 {
    
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline)
        external
        returns (uint[] memory amounts);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

}

interface IUniswapV2Factory {
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract DuckButt is IERC20 {  
      
    string public constant name = "DuckButt";
    string public constant symbol = "DUBU";
    uint8 public constant decimals = 8;
    uint256 public totalSupply;  

    address public COMMUNITYWALLET = 0x761Eb6556c69B6484e2FDbd76C527cC4e3628Ae0; 
    uint256 public THRESHOLD = 1000000 * 10 ** 8;
    uint256 public MAXWALLET;

    address private _deployer;
    Tax private _tax;
  
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) private isPair;
    mapping(address => bool) private isExempt;
    
    address private _owner = address(0);
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router01 public uniswapV2Router;
    address public uniswapV2Pair; 
    bool inLiquidate;

    event Liquidate(uint256 _ethForCommunity, uint256 _ethForLiquidity, uint256 _tokensForLiquidity);
    event SetTaxBalance(uint256 _communityTax, uint256 _liquidityTax);
    event TransferOwnership(address _newDev);
    event SetCommunityWallet(address _communityWallet);
    event UpdateExempt(address _address, bool _isExempt);
    event AddPair(address _pair);
    event UpdateMaxWallet(uint256 _maxWallet);
 

    constructor() {
        _deployer = msg.sender;
        _update(address(0), msg.sender, 1000000000 * 10 ** 8);
        uniswapV2Router = IUniswapV2Router01(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        MAXWALLET = totalSupply * 1 / 200;

        _tax = Tax(50, 50, 42069);

        isPair[address(uniswapV2Pair)] = true; 
        isExempt[msg.sender] = true;
        isExempt[address(this)] = true;

        allowance[address(this)][address(uniswapV2Pair)] = totalSupply;
        allowance[address(this)][address(uniswapV2Router)] = totalSupply;

        inLiquidate = false;
    } 

    struct Tax {
        uint8 communityTax;
        uint8 liquidityTax;
        uint16 txFee;
    }

    receive() external payable {}

    modifier protected {
        require(msg.sender == _deployer);
        _;
    }

    modifier lockLiquidate {
        inLiquidate = true;
        _;
        inLiquidate = false;
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
        
    }

    function transfer(address to, uint256 amount) external override returns (bool) {
         _transferFrom(msg.sender, to, amount);   
         return true; 
    } 

    function transferFrom(address from, address to, uint256 amount) external override returns (bool) {
        if (allowance[from][msg.sender] != totalSupply) {            
            allowance[from][msg.sender] -= amount;
        }

        _transferFrom(from, to, amount);
        return true;
    }   

    function _transferFrom(address from, address to, uint256 amount) private returns (bool) {

        require(amount > 0);
        require(amount <= balanceOf[from]);      

        if(isExempt[from] || isExempt[to] || inLiquidate) {
            _update(from, to, amount);
            return true;
        }

        if(!isPair[to]) {
        require((balanceOf[to] + amount) <= MAXWALLET);
        }

        if(balanceOf[address(this)] >= THRESHOLD && !inLiquidate && isPair[to]) {
            _liquidate();
        }

        uint256 fee = 0; 

        if(isPair[from] || isPair[to]) {
            fee = amount * _tax.txFee / 10**6;            
        }     

        balanceOf[address(this)] += fee;
        balanceOf[from] -= amount;
        balanceOf[to] += (amount - fee); 

        emit Transfer(from, to, amount);  
        return true;                
    } 

    function _update(address from, address to, uint256 amount) private {
        if(from != address(0)){
            balanceOf[from] -= amount;
        }else{
            totalSupply += amount;
        }
        if(to == address(0)){
            totalSupply -= amount;
        }else{
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
    }

    function _liquidate() private lockLiquidate {
        
        uint256 tokensForLiquidity = (THRESHOLD * _tax.liquidityTax / 100);
        uint256 half = tokensForLiquidity / 2;
        uint256 tokensToSwap = (THRESHOLD - half);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        uniswapV2Router.swapExactTokensForETH(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp + 15
        );

        uint256 totalEth = address(this).balance;
        uint256 ethForCommunity = totalEth * _tax.communityTax / 100;
        uint256 ethForLiquidity = totalEth - ethForCommunity;
           
        (bool sent, ) = payable(COMMUNITYWALLET).call{value:ethForCommunity}("");
        require(sent);

        if (tokensForLiquidity > 0) {           
            uniswapV2Router.addLiquidityETH{value: ethForLiquidity}(
            address(this),
            tokensForLiquidity,
            0,
            0,
            DEAD,
            block.timestamp + 15);
        }

        emit Liquidate(ethForCommunity, ethForLiquidity, tokensForLiquidity);
          
    }

    function setTaxBalance(uint8 _communityTax, uint8 _liquidityTax) external protected {

        require(_communityTax + _liquidityTax >= 0 && _communityTax + _liquidityTax <= 100);
        
        _tax.communityTax = _communityTax;
        _tax.liquidityTax = _liquidityTax;

        emit SetTaxBalance(_communityTax, _liquidityTax);  
    }

    function setCommunityWallet(address payable newCommunityWallet) external protected {
        COMMUNITYWALLET = newCommunityWallet;
        emit SetCommunityWallet(newCommunityWallet);       
    }

    function setMaxWallet(uint8 percentage) external protected {
        MAXWALLET = totalSupply * percentage / 100;
        emit UpdateMaxWallet(MAXWALLET);
    }

    function transferOwnership(address _newDev) external protected {
        isExempt[_deployer] = false;
        _deployer = _newDev;
        isExempt[_deployer] = true;  
        emit TransferOwnership(_newDev);    
    }

    function clearStuckEth() external protected {
        uint256 contractETHBalance = address(this).balance;
        if(contractETHBalance > 0){          
            (bool sent, ) = payable(COMMUNITYWALLET).call{value:contractETHBalance}("");
            require(sent);
        }
        emit Transfer(address(this), COMMUNITYWALLET, contractETHBalance);
    }

    function manualLiquidate() external protected {
        require(balanceOf[address(this)] >= THRESHOLD);
        _liquidate();
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

}