pragma solidity >=0.6.0 <0.8.0; 

// SPDX-License-Identifier: GTFO 

// RandomAura Proxy: 0x326225AEEa3D45435A53e9Dd801A6Ee8155006e5 

 

import "./tool-safemath.sol"; 

interface IERC1155 { 

  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external; 

  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external; 

  function balanceOf(address _owner, uint256 _id) external view returns (uint256); 

  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory); 

  function setApprovalForAll(address _operator, bool _approved) external; 

  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator); 

   

  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount); 

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts); 

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved); 

} 

interface IERC20 { 

    function totalSupply() external view returns (uint256); 

    function balanceOf(address account) external view returns (uint256); 

    function allowance(address owner, address spender) external view returns (uint256); 

    function transfer(address recipient, uint256 amount) external returns (bool); 

    function approve(address spender, uint256 amount) external returns (bool); 

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool); 

 

    event Transfer(address indexed from, address indexed to, uint256 value); 

    event Approval(address indexed owner, address indexed spender, uint256 value); 

} 

interface Rnd { 

    function seedUp() external view returns(uint256); 

    function seedDw() external view returns(uint256); 

    function useSeed() external; 

} 

 

 

//-------------------Contracts-------------------------------  

contract RareLottoMulti { 

    //-------------------Libraries--------------------------- 

     

    using SafeMath for uint; 

    using SafeMath for uint8; 

    using SafeMath for uint16; 

    using SafeMath for uint32; 

    using SafeMath for uint64; 

    //-------------------Storage-----------------------------     

    Rnd private random; // address of My xdai instance of random     

    IERC20 private rare; // creates an contract type, named rare 

    IERC1155 private nftChance;  

    IERC1155 private nft1;   

    uint16 private nft1id;   

    uint16 private nftChanceId;   

     

    uint private constant BLOCKS_PER_DAY = 17000; // real days 17000, median between 6 & 5 second block time | 30 for testing 

    uint private constant LUCKY_NUMBER = 5;  

     

    address payable private manager; 

    address[] private players;  

    uint64 public fee; // in evm.com instace, must be unchangeable TODO  

    uint64 public commission; 

    uint public blockTarget;   

    address public lastWinner;  

    uint16 public drawCount;  

 

    struct Info { 

        uint16 lastEntry; 

        uint16 timesEntered;  

        uint64 numRef;  

        uint lastSeed; 

        uint64 doubleCount;  

    } 

     

    //-------------------Mappings--------------------------- 

    mapping(address => Info) private gambler;   

     

    //-------------------Events----------------------------- 

    event NewWinner(address indexed _adr,  uint indexed _timesEntered, uint16 indexed _drawCount);       

     

    //-------------------Contructor------------------------- 

    constructor( Rnd _randomContractAddress, IERC20 _tokenAddress, IERC1155 _nftChance, uint16 _nftChanceId, IERC1155 _nft1, uint16 _id1,  uint _durationindays) { 

        require(_durationindays >= 1, "Must be 1 Day Or Longer");  

        manager = msg.sender; 

        random = _randomContractAddress; 

        rare = _tokenAddress; 

        nftChance = _nftChance; 

        nftChanceId = _nftChanceId; 

        nft1 = _nft1; 

        nft1id = _id1; 

        random.useSeed(); 

        fee = 5 ether;  

        commission = 2 ether;   

        blockTarget = block.number.add(BLOCKS_PER_DAY.mul(_durationindays)); 

    } 

    //-------------------Public Functions-------------------   

     

    // #regester for lottery With Affiliate  

    function enter(address payable _ref) public payable alw { 

        require(msg.value >= fee, "You must cover the xDai transaction fee"); 

        uint16 numEntry = 1;  

        // incresses entry stat, or resets enteries if on new draw 

        if (drawCount == gambler[msg.sender].lastEntry) { 

            gambler[msg.sender].timesEntered = uint16(gambler[msg.sender].timesEntered.add(1)); 

        } else { 

            gambler[msg.sender].timesEntered = 1; 

            gambler[msg.sender].lastEntry = drawCount;  

            gambler[msg.sender].doubleCount = 0;  

        } 

        //  check if owns nft  

        if (hasCosmix() == true) { 

            // sets and gets latest seed for nft change  

            random.useSeed(); 

            uint seed = getSeed(); 

            // if numbers match double times entered!  

            if (getPerkChance(msg.sender) == LUCKY_NUMBER) {  

                gambler[msg.sender].lastSeed = seed;  

                numEntry = gambler[msg.sender].timesEntered;  

                gambler[msg.sender].timesEntered = uint16(gambler[msg.sender].timesEntered.mul(2));  

                gambler[msg.sender].doubleCount = uint16(gambler[msg.sender].doubleCount.add(1)); 

            } 

        } 

         

        // sends user NFT if there are any left to give 

        if (nft1.balanceOf(manager,nft1id) > 1) { 

        nft1.safeTransferFrom(manager,msg.sender,nft1id,1,"0x0"); 

        } 

        // adds player to draw  

        if(_ref == 0x0000000000000000000000000000000000000000 || _ref == msg.sender){ 

        // if ref address is blank or self, just ad self once, unless chance card activates  

            for (uint16 i; i < numEntry ; i++){ 

            players.push(msg.sender); 

            } 

        } else { 

        // if ref valid, incresses entry and ref count stat for ref, or resets enteries if on new draw then adds ref and self to draw & pay commision 

            if (drawCount == gambler[_ref].lastEntry) { 

                gambler[_ref].numRef = uint64(gambler[_ref].numRef.add(1)); 

            } else { 

                gambler[_ref].numRef = 1;  

                gambler[_ref].lastEntry = drawCount;  

            } 

            // adds player amount of times  

            for (uint i; i < numEntry ; i++){ 

            players.push(msg.sender); 

            } 

            players.push(_ref); 

            _ref.transfer(commission);  

        } 

    } 

    // #picks the winner single 

    function pickWinner() public restricted blk {  

        // uint seed = _seed; // for test only ... uint _seed 

        // sets the seed via call 

        random.useSeed(); 

        //gets the new seed  

        uint seed = getSeed(); 

        //calcuates random 

        uint i = seed.mod(players.length); 

        // Calculate Token Prize 

        uint winnerAmt = rare.balanceOf(address(this)); 

        // selects winner from id and sends contract balance to user   

        rare.transfer(payable(players[i]), winnerAmt);  

        // posts winner  

        lastWinner = players[i]; 

        // sends a winner event 

        emit NewWinner(players[i],gambler[msg.sender].timesEntered,drawCount);    

        // resets the players arrary, by creating a new empty dynamic array with 0 length 

        players = new address[](0); 

        // adds counts winner 

        drawCount = uint16(drawCount.add(1));  

        // Pays Host Their Ticket Money 

        manager.transfer(address(this).balance);  

    } 

      // #picks the winner multi | temp function, unsafe for evmlotto since seed takes 17 blocks to reset 

    function pickWinners(uint _amtinWei) public restricted blk {  

        // If not enough lotto token in contract then call will fail 

        require(rare.balanceOf(address(this)) >= _amtinWei, "Not Enough Token In Contract"); 

        // sets the seed via call 

        random.useSeed(); 

        //gets the new seed 

        uint seed = blockNow().add(getSeed()); 

        //calcuates random 

        uint i = seed.mod(players.length); 

        // Calculate Token Prize 

        uint winnerAmt = _amtinWei; 

        // selects winner from id and sends contract balance to user   

        rare.transfer(payable(players[i]), winnerAmt);  

        // posts winner  

        lastWinner = players[i]; 

        // sends a winner event 

        emit NewWinner(players[i],gambler[msg.sender].timesEntered,drawCount);    

    } 

    // manually resets the lotto | temp function, unsafe for evmlotto since does not draw  

    function endLotto() public restricted blk {  

        // resets the players arrary, by creating a new empty dynamic array with 0 length 

        players = new address[](0); 

        // adds counts winner 

        drawCount = uint16(drawCount.add(1));  

        // Pays Host Their Ticket Money 

        manager.transfer(address(this).balance);  

    } 

         

    //-------------------View Functions---------------------    

     

    // #gets number of players in lottoy  

    function getPlayersNum() public view returns (uint) { 

        return players.length; 

    }     

    // #cheaks balance of rare tokens this contract adress has (pot)  

    function getJackpotAmt() public view returns (uint) { 

        return rare.balanceOf(address(this)); 

    } 

     

         

    // #get my number of total entries 

    function getMyEntires() public view returns (uint) { 

        if(gambler[msg.sender].lastEntry == drawCount) { 

            return gambler[msg.sender].timesEntered.add(gambler[msg.sender].numRef); 

        } else { 

            return 0;   

        } 

    }  

     

     

    // #get my number of self entries 

    function getMySelfEntires() public view returns (uint) { 

        if(gambler[msg.sender].lastEntry == drawCount) { 

            return gambler[msg.sender].timesEntered; 

        } else { 

            return 0;   

        } 

    }  

     

     

    // #get my number of referals 

    function getMyRefs() public view returns (uint) { 

        if(gambler[msg.sender].lastEntry == drawCount) { 

            return gambler[msg.sender].numRef; 

        } else { 

            return 0;   

        } 

    }  

     

    // #returns count of times entries doubles from nft perk 

    function getTimesDoubled() public view returns (uint) { 

        if(gambler[msg.sender].lastEntry == drawCount) { 

            return gambler[msg.sender].doubleCount; 

        } else { 

            return 0;   

        } 

    }  

     

     

    // #get basispoints of winning balance 100% = 1000000  

    function getLuck() public view returns (uint) { 

        if (gambler[msg.sender].timesEntered == 0){ 

        return 0; 

        } else { 

            if(gambler[msg.sender].lastEntry == drawCount) { 

            return (gambler[msg.sender].timesEntered.add(gambler[msg.sender].numRef).mul(1000000)).div(getPlayersNum()); 

            } else { 

            return 0;  

            } 

        } 

         

    } 

     

     

    // #returns true if user owns nft perk 

    function hasCosmix() public view returns (bool) { 

        if(nftChance.balanceOf(msg.sender, nftChanceId) >= 1) { 

            return true; 

        } else { 

            return false;   

        } 

    }  

     

    //-------------------Internal Functions-----------------    

     

    // Gets seed from contract 

    function getSeed() private view returns (uint){ 

        uint seed;  

        if(random.seedUp() == random.seedDw()){ 

            seed = random.seedDw(); 

        } else { 

            seed = random.seedUp();  

        } 

        return seed; 

    }   

     

     

    // checks if user has NFT, if does returns chance else returns 0  

    function getPerkChance(address _adr) private alw view returns (uint){ 

        if (nftChance.balanceOf(_adr, nftChanceId) >= 1){ 

            uint seed = getSeed(); 

            return blockNow().add(seed).mod(10); 

        } else { 

            return 0;  

        } 

    } 

     

     

    //-------------------Manager Functions------------------  

    // *creates a restricted fuction unless you are the manager 

    modifier restricted() { 

        require(msg.sender == manager, "You are not the manager"); 

        _; 

    }     

     

    // sets a new manager of the contract  

    function setManager(address payable _newManager) public restricted { 

        manager = _newManager; 

    } 

     

     

    // #sets fee price of each ticket  

    function setFee(uint64 _fee) public restricted { 

        require(_fee <= 100 ether, "Cant set the dev fee higher then 100 xDai"); 

        fee = _fee;  

    }   

     

    // #sets commission in wei of amount payed to referal  

    function setCommission(uint64 _commission) public restricted { 

        require(_commission <= fee, "Can't set the ref commission higher then the required fee"); 

        commission = _commission;  

    }   

     

    // #resets the block timer  

    function resetTimer(uint _durationindays) public restricted { 

        blockTarget = block.number.add(BLOCKS_PER_DAY.mul(_durationindays)); 

    }       

     

    // #sets token address 

    function setRewardToken(IERC20 _tokenAddress) public restricted { 

        rare = _tokenAddress; 

    }   

     

    // #set the ticket NFT addresses, only manager 

    function setNFTAddrs(address _nft1, uint16 _id1) public restricted {  

        nft1 = IERC1155(_nft1); 

        nft1id = _id1; 

    } 

     

    // #gets addresses of players in lottoy  

    function getPlayersAddresses() public restricted view returns (address[] memory) { 

        return players; 

    }     

    

 

    //-------------------timr Functions---------------------   

    function blockNow() public view returns (uint) {  

        return block.number;   

    }      

     

    function blocksLeft() public view returns (uint) {   

        if(blockTarget <= block.number){ 

            return 0;  

        } else {  

            return blockTarget.sub(blockNow()); 

        } 

    } 

     

    // ---------------- **Locked Based on Timer** --------- 

    //   while (blockTarget >= currentBlock) = true, unlocked  

    //   while (blockTarget <= currentBlock) = untrue, locked 

     

    modifier alw() { 

        require(blockTarget >= block.number, "Lottery Closed, Draw Will Start Shortly"); // allow before target reached 

        _; 

    }      

 

    modifier blk() { 

        require(blockTarget <= block.number, "Can't Pick Winner Until Timer Expires"); // allow after target reached 

        _; 

    }       

     

    //-------------------End Of Contract ------------------ 

     

} 