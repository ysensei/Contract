pragma solidity ^0.4.0;

contract finneyQuiz{
    
    address public owner;
    mapping (uint256 => uint256) public winnersResult;
    uint period = 1;
    uint currentNum = 0;
    uint256[] betsArrays ;
    uint16 index = 0;

    function finneyQuiz() public payable{
        owner = msg.sender;
    }
    
    function () public payable{
        if(msg.value < 1000000000000000 ) return;

        currentNum += msg.value/(1000000000000000);
        if(currentNum>1000){
            msg.sender.transfer((currentNum-1000)*1000000000000000);
            currentNum = 1000;
        }
        // tell users number
        msg.sender.transfer(currentNum*10+1);

        uint256 bets = 0;
        bets |= currentNum << 240;
        bets |= uint(msg.sender);
        
        //betsArrays.push(bets);
        if(index == betsArrays.length) {
            //betsArrays.length += 1;
            betsArrays.push(bets);
        }else{
            betsArrays[index] = bets;
        }
        index++;

        if(currentNum >= 1000){
            uint256 number = 0 ;
            uint256 random = uint16(randomNum()%1000+1);
            number |= random <<240;
            number = betsArrays[binarySearch(number)];
            //this number means (1<<240)-1
            number = number & (1766847064778384329583297500742918515827483896875618958121606201292619775);
            address winnerAddr = address(number);
            
            currentNum = 0 ;
            //betsArrays.length = 0;
            index = 0;
            
            uint256 result = 0;
            result |= random <<168;
            result |= block.number << 184;
            result |= uint(winnerAddr);
            
            winnersResult[period] = result;
            
            period++;
            if(this.balance >= 999000000000000000){
                winnerAddr.transfer(990000000000000000);
                msg.sender.transfer(4000000000000000);
            }else{
                winnerAddr.transfer(this.balance*99/100);
            }
        }
    }
    
    function binarySearch(uint num) internal returns (uint){
        if(index==1) return 0;
        if(num < betsArrays[0]) return 0;
        
        uint low = 0;
        //uint high = betsArrays.length-1;
        uint high = index-1;

        while(low < high ){
            uint middle = (low+high)/2;
            if(low+1 == high){
                return high;
            }
            if(num > betsArrays[middle]){
                low = middle;
            }else{
                high = middle;
            }
        }
        return 0;
    }
    
    function randomNum() view internal returns (uint) {
        uint bhash = uint(block.blockhash(block.number));
        uint num = bhash + (block.timestamp * (block.difficulty + period));
        num = uint(keccak256(num));
        return num;
    }

    function getPrizeResult(uint pd) view public returns(address,uint, uint ){
        uint result = winnersResult[pd];
        uint blockNo = result >>184;
        uint prizeNo = (result << 72) >>240 ;
        uint addressNo = (result << 88) >> 88;
        return (address(addressNo),prizeNo,blockNo);
    }

    function getEthers(address addr ,uint amount) public payable{
        if(msg.sender != owner) return;
        addr.transfer(amount);
    }
  
    function getBalance() view public returns(uint){
        return this.balance;
    }
    
    function getCurrentPeriod() view public returns(uint){
        return period;
    }
    
    function getCurrentNumber()view public returns(uint){
        return currentNum;
    }
}