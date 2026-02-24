# RARE-ERC20 Contract Audit

## Contract Overview

**File:** RARE-ERC20.sol
**Solidity:** >=0.6.0 <0.8.0
**Type:** Custom ERC20 Token
**Total Supply:** 36,500 RARE (⚠️ User wants 1,000,000)

---

## 🔴 CRITICAL ISSUES

### 1. Wrong Total Supply
```solidity
totalSupply = 36500000000000000000000; // 36,500 RARE
```
**Issue:** User specified **1,000,000 RARE** but contract has 36,500.

**Fix:**
```solidity
totalSupply = 1000000000000000000000000; // 1,000,000 RARE (18 decimals)
```

### 2. Solidity Version (0.6.x - 0.7.x)
```solidity
pragma solidity >=0.6.0 <0.8.0;
```
**Issue:** No built-in overflow protection. 0.8.x has automatic overflow checks.

**Fix:**
```solidity
pragma solidity ^0.8.20;
```

### 3. No Zero Address Checks
```solidity
function transfer(address _to, uint _value) public returns (bool) {
    // No check for _to == address(0)
```
**Issue:** Tokens can be sent to address(0) and lost forever.

**Fix:**
```solidity
require(_to != address(0), "Cannot transfer to zero address");
```

### 4. No SafeMath
**Issue:** In Solidity 0.6.x, arithmetic operations don't automatically revert on overflow.

**Current code uses assert() which is wrong approach:**
```solidity
assert(balanceOf[_to] + _value >= balanceOf[_to]);
```

**Fix:** Upgrade to 0.8.x OR use SafeMath.

---

## 🟡 MEDIUM ISSUES

### 5. Custom ERC20 Instead of OpenZeppelin
**Issue:** Custom implementations have more bugs than battle-tested OpenZeppelin.

**Recommendation:** Use OpenZeppelin ERC20:
```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RareToken is ERC20 {
    constructor(address _ftnAddress) ERC20("Rare Coin", "RARE") {
        _mint(_ftnAddress, 1000000 * 10**decimals());
    }
}
```

### 6. Approve Function Has TODO Comment
```solidity
// makes sure that user is not allowing more then they have, if they try it fails *TODO test --------------
require(balanceOf[msg.sender] >= _value, "Not enough tokens in account");
```
**Issue:** This requirement is non-standard. ERC20 approve should allow approving more than balance (for future tokens).

**Standard behavior:** Remove this require.

### 7. Assert Usage Incorrect
```solidity
assert(balanceOf[_to] + _value >= balanceOf[_to]);
```
**Issue:** 
- `assert` is for internal invariants, not input validation
- In 0.6.x, `assert` consumes ALL gas on failure
- Should use `require` for validation

### 8. No Burn Function
**Issue:** No way to burn tokens if needed for future mechanics.

### 9. No Mint Function
**Issue:** No way to mint after deployment (which is actually good for fixed supply).

### 10. No Owner/Access Control
**Issue:** No ownership, no admin functions. This is actually fine for a fixed supply token.

---

## 🟢 POSITIVE FINDINGS

1. ✅ Events are properly emitted
2. ✅ Transfer returns bool as per ERC20
3. ✅ Approve returns bool as per ERC20
4. ✅ TransferFrom decreases allowance correctly
5. ✅ All balances updated correctly
6. ✅ Fixed supply (no inflation)

---

## 📋 RECOMMENDED REWRITE

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RareToken is ERC20 {
    constructor(address _ftnAddress) ERC20("Rare Coin", "RARE") {
        // 1,000,000 RARE with 18 decimals
        _mint(_ftnAddress, 1000000 * 10**decimals());
    }
}
```

**Benefits of OpenZeppelin version:**
- Battle-tested, audited code
- Built-in overflow protection (0.8.x)
- Standard ERC20 compliance
- ~30 lines vs ~80 lines
- No bugs

---

## 🔧 IF KEEPING CUSTOM IMPLEMENTATION

Required fixes:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RareToken {
    string public constant name = "Rare Coin";
    string public constant symbol = "RARE";
    uint8 public constant decimals = 18;
    uint public constant totalSupply = 1000000 * 10**18; // 1M tokens
    
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
    
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    
    constructor(address _ftnAddress) {
        require(_ftnAddress != address(0), "Invalid address");
        balanceOf[_ftnAddress] = totalSupply;
        emit Transfer(address(0), _ftnAddress, totalSupply);
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(balanceOf[msg.sender] >= _value, "Not enough tokens");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool) {
        require(_spender != address(0), "Invalid spender");
        
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(_to != address(0), "Cannot transfer to zero address");
        require(_value <= balanceOf[_from], "Not enough tokens");
        require(_value <= allowance[_from][msg.sender], "Not allowed");
        
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        
        emit Transfer(_from, _to, _value);
        return true;
    }
}
```

---

## SUMMARY

| Issue | Severity | Fix Required |
|-------|----------|--------------|
| Wrong supply (36,500 vs 1M) | 🔴 Critical | Yes |
| Solidity 0.6.x | 🔴 Critical | Yes |
| No zero address checks | 🔴 Critical | Yes |
| No SafeMath | 🔴 Critical | Yes |
| Assert misuse | 🟡 Medium | Yes |
| Non-standard approve | 🟡 Medium | Yes |
| Custom vs OpenZeppelin | 🟡 Medium | Recommended |

---

## RECOMMENDATION

**Use OpenZeppelin ERC20** - 5 lines of code, battle-tested, no bugs.

---

*Audit completed: 2026-02-24*
*Auditor: Felix*
