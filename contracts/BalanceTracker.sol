pragma solidity 0.7.3;

import "./IERC20.sol";
import "./SafeMath.sol";

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [// importANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * // importANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


contract HitchensOrderStatisticsTree {

    uint private constant EMPTY = 0;
    struct Node {
        uint parent;
        uint left;
        uint right;
        bool red;
        bytes32[] keys;
        mapping(bytes32 => uint) keyMap;
        uint count;
    }
    struct Tree {
        uint root;
        mapping(uint => Node) nodes;
    }

    Tree tree;

    function first(Tree storage self) internal view returns (uint _value) {
        _value = self.root;
        if(_value == EMPTY) return 0;
        while (self.nodes[_value].left != EMPTY) {
            _value = self.nodes[_value].left;
        }
    }
    function last(Tree storage self) internal view returns (uint _value) {
        _value = self.root;
        if(_value == EMPTY) return 0;
        while (self.nodes[_value].right != EMPTY) {
            _value = self.nodes[_value].right;
        }
    }
    function next(Tree storage self, uint value) internal view returns (uint _cursor) {
        require(value != EMPTY, "OrderStatisticsTree(401) - Starting value cannot be zero");
        if (self.nodes[value].right != EMPTY) {
            _cursor = treeMinimum(self, self.nodes[value].right);
        } else {
            _cursor = self.nodes[value].parent;
            while (_cursor != EMPTY && value == self.nodes[_cursor].right) {
                value = _cursor;
                _cursor = self.nodes[_cursor].parent;
            }
        }
    }
    function prev(Tree storage self, uint value) internal view returns (uint _cursor) {
        require(value != EMPTY, "OrderStatisticsTree(402) - Starting value cannot be zero");
        if (self.nodes[value].left != EMPTY) {
            _cursor = treeMaximum(self, self.nodes[value].left);
        } else {
            _cursor = self.nodes[value].parent;
            while (_cursor != EMPTY && value == self.nodes[_cursor].left) {
                value = _cursor;
                _cursor = self.nodes[_cursor].parent;
            }
        }
    }
    function exists(Tree storage self, uint value) internal view returns (bool _exists) {
        if(value == EMPTY) return false;
        if(value == self.root) return true;
        if(self.nodes[value].parent != EMPTY) return true;
        return false;       
    }
    function keyExists(Tree storage self, bytes32 key, uint value) internal view returns (bool _exists) {
        if(!exists(self, value)) return false;
        return self.nodes[value].keys[self.nodes[value].keyMap[key]] == key;
    } 
    function getNode(Tree storage self, uint value) internal view returns (uint _parent, uint _left, uint _right, bool _red, uint keyCount, uint count) {
        require(exists(self,value), "OrderStatisticsTree(403) - Value does not exist.");
        Node storage gn = self.nodes[value];
        return(gn.parent, gn.left, gn.right, gn.red, gn.keys.length, gn.keys.length+gn.count);
    }
    function getNodeCount(Tree storage self, uint value) internal view returns(uint count) {
        Node storage gn = self.nodes[value];
        return gn.keys.length+gn.count;
    }
    function valueKeyAtIndex(Tree storage self, uint value, uint index) internal view returns(bytes32 _key) {
        require(exists(self,value), "OrderStatisticsTree(404) - Value does not exist.");
        return self.nodes[value].keys[index];
    }
    function count(Tree storage self) internal view returns(uint _count) {
        return getNodeCount(self,self.root);
    }
    function percentile(Tree storage self, uint value) internal view returns(uint _percentile) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _percentile = ((uint(1000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function permil(Tree storage self, uint value) internal view returns(uint _permil) {
        uint denominator = count(self);
        uint numerator = rank(self, value);
        _permil = ((uint(10000) * numerator)/denominator+(uint(5)))/uint(10);
    }
    function atPercentile(Tree storage self, uint _percentile) internal view returns(uint _value) {
        uint findRank = (((_percentile * count(self))/uint(10)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }
    function atPermil(Tree storage self, uint _permil) internal view returns(uint _value) {
        uint findRank = (((_permil * count(self))/uint(100)) + uint(5)) / uint(10);
        return atRank(self,findRank);
    }    
    function median(Tree storage self) internal view returns(uint value) {
        return atPercentile(self,50);
    }
    function below(Tree storage self, uint value) internal view returns(uint) {
        if(count(self) > 0 && value > 0) {
            uint valueRank = rank(self,value);

            if(valueRank == 0) {
                return 0;
            }

            uint256 valueAtRank = atRank(self,valueRank);

            uint256 add = 0;
            if(valueRank <= count(self) && valueAtRank <= value) {
                add = 1;
            }

            return valueRank - 1 + add;
        }
    }
    function above(Tree storage self, uint value) internal view returns(uint) {
        if(count(self) > 0) {
            uint valueRank = rank(self,value);

            uint treeCount = count(self);

            if(valueRank > treeCount) {
                return 0;
            }

            uint256 valueAtRank = atRank(self,valueRank);

            uint256 add = 0;
            if(valueRank > 0 && valueAtRank >= value) {
                add = 1;
            }

            return treeCount - valueRank + add;
        }
    } 
    function rank(Tree storage self, uint value) internal view returns(uint _rank) {
        if(count(self) > 0) {
            bool finished;
            uint cursor = self.root;
            Node storage c = self.nodes[cursor];
            uint smaller = getNodeCount(self,c.left);
            while (!finished) {
                uint keyCount = c.keys.length;
                if(cursor == value) {
                    finished = true;
                } else {
                    if(cursor < value) {
                        cursor = c.right;
                        c = self.nodes[cursor];
                        smaller += keyCount + getNodeCount(self,c.left);
                    } else {
                        cursor = c.left;
                        c = self.nodes[cursor];
                        smaller -= (keyCount + getNodeCount(self,c.right));
                    }
                }
                if (!exists(self,cursor)) {
                    finished = true;
                }
            }
            return smaller + 1;
        }
    }
    function atRank(Tree storage self, uint _rank) internal view returns(uint _value) {
        bool finished;
        uint cursor = self.root;
        Node storage c = self.nodes[cursor];
        uint smaller = getNodeCount(self,c.left);
        while (!finished) {
            _value = cursor;
            c = self.nodes[cursor];
            uint keyCount = c.keys.length;
            if(smaller + 1 >= _rank && smaller + keyCount <= _rank) {
                _value = cursor;
                finished = true;
            } else {
                if(smaller + keyCount <= _rank) {
                    cursor = c.right;
                    c = self.nodes[cursor];
                    smaller += keyCount + getNodeCount(self,c.left);
                } else {
                    cursor = c.left;
                    c = self.nodes[cursor];
                    smaller -= (keyCount + getNodeCount(self,c.right));
                }
            }
            if (!exists(self,cursor)) {
                finished = true;
            }
        }
    }
    function insert(Tree storage self, bytes32 key, uint value) internal {
        require(value != EMPTY, "OrderStatisticsTree(405) - Value to insert cannot be zero");
        require(!keyExists(self,key,value), "OrderStatisticsTree(406) - Value and Key pair exists. Cannot be inserted again.");
        uint cursor;
        uint probe = self.root;
        while (probe != EMPTY) {
            cursor = probe;
            if (value < probe) {
                probe = self.nodes[probe].left;
            } else if (value > probe) {
                probe = self.nodes[probe].right;
            } else if (value == probe) {
                self.nodes[probe].keys.push(key);
                self.nodes[probe].keyMap[key] = self.nodes[probe].keys.length - uint(1);
                return;
            }
            self.nodes[cursor].count++;
        }
        Node storage nValue = self.nodes[value];
        nValue.parent = cursor;
        nValue.left = EMPTY;
        nValue.right = EMPTY;
        nValue.red = true;
        nValue.keys.push(key);
        nValue.keyMap[key] = nValue.keys.length - uint(1);
        if (cursor == EMPTY) {
            self.root = value;
        } else if (value < cursor) {
            self.nodes[cursor].left = value;
        } else {
            self.nodes[cursor].right = value;
        }
        insertFixup(self, value);
    }
    function remove(Tree storage self, bytes32 key, uint value) internal {
        require(value != EMPTY, "OrderStatisticsTree(407) - Value to delete cannot be zero");
        require(keyExists(self,key,value), "OrderStatisticsTree(408) - Value to delete does not exist.");
        Node storage nValue = self.nodes[value];
        uint rowToDelete = nValue.keyMap[key];
        nValue.keys[rowToDelete] = nValue.keys[nValue.keys.length - uint(1)];
        nValue.keyMap[nValue.keys[rowToDelete]]=rowToDelete;
        nValue.keys.pop();
        uint probe;
        uint cursor;
        if(nValue.keys.length == 0) {
            if (self.nodes[value].left == EMPTY || self.nodes[value].right == EMPTY) {
                cursor = value;
            } else {
                cursor = self.nodes[value].right;
                while (self.nodes[cursor].left != EMPTY) { 
                    cursor = self.nodes[cursor].left;
                }
            } 
            if (self.nodes[cursor].left != EMPTY) {
                probe = self.nodes[cursor].left; 
            } else {
                probe = self.nodes[cursor].right; 
            }
            uint cursorParent = self.nodes[cursor].parent;
            self.nodes[probe].parent = cursorParent;
            if (cursorParent != EMPTY) {
                if (cursor == self.nodes[cursorParent].left) {
                    self.nodes[cursorParent].left = probe;
                } else {
                    self.nodes[cursorParent].right = probe;
                }
            } else {
                self.root = probe;
            }
            bool doFixup = !self.nodes[cursor].red;
            if (cursor != value) {
                replaceParent(self, cursor, value); 
                self.nodes[cursor].left = self.nodes[value].left;
                self.nodes[self.nodes[cursor].left].parent = cursor;
                self.nodes[cursor].right = self.nodes[value].right;
                self.nodes[self.nodes[cursor].right].parent = cursor;
                self.nodes[cursor].red = self.nodes[value].red;
                (cursor, value) = (value, cursor);
                fixCountRecurse(self, value);
            }
            if (doFixup) {
                removeFixup(self, probe);
            }
            fixCountRecurse(self, cursorParent);
            delete self.nodes[cursor];
        }
    }
    function fixCountRecurse(Tree storage self, uint value) private {
        while (value != EMPTY) {
           self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
           value = self.nodes[value].parent;
        }
    }
    function treeMinimum(Tree storage self, uint value) private view returns (uint) {
        while (self.nodes[value].left != EMPTY) {
            value = self.nodes[value].left;
        }
        return value;
    }
    function treeMaximum(Tree storage self, uint value) private view returns (uint) {
        while (self.nodes[value].right != EMPTY) {
            value = self.nodes[value].right;
        }
        return value;
    }
    function rotateLeft(Tree storage self, uint value) private {
        uint cursor = self.nodes[value].right;
        uint parent = self.nodes[value].parent;
        uint cursorLeft = self.nodes[cursor].left;
        self.nodes[value].right = cursorLeft;
        if (cursorLeft != EMPTY) {
            self.nodes[cursorLeft].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].left) {
            self.nodes[parent].left = cursor;
        } else {
            self.nodes[parent].right = cursor;
        }
        self.nodes[cursor].left = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
        self.nodes[cursor].count = getNodeCount(self,self.nodes[cursor].left) + getNodeCount(self,self.nodes[cursor].right);
    }
    function rotateRight(Tree storage self, uint value) private {
        uint cursor = self.nodes[value].left;
        uint parent = self.nodes[value].parent;
        uint cursorRight = self.nodes[cursor].right;
        self.nodes[value].left = cursorRight;
        if (cursorRight != EMPTY) {
            self.nodes[cursorRight].parent = value;
        }
        self.nodes[cursor].parent = parent;
        if (parent == EMPTY) {
            self.root = cursor;
        } else if (value == self.nodes[parent].right) {
            self.nodes[parent].right = cursor;
        } else {
            self.nodes[parent].left = cursor;
        }
        self.nodes[cursor].right = value;
        self.nodes[value].parent = cursor;
        self.nodes[value].count = getNodeCount(self,self.nodes[value].left) + getNodeCount(self,self.nodes[value].right);
        self.nodes[cursor].count = getNodeCount(self,self.nodes[cursor].left) + getNodeCount(self,self.nodes[cursor].right);
    }
    function insertFixup(Tree storage self, uint value) private {
        uint cursor;
        while (value != self.root && self.nodes[self.nodes[value].parent].red) {
            uint valueParent = self.nodes[value].parent;
            if (valueParent == self.nodes[self.nodes[valueParent].parent].left) {
                cursor = self.nodes[self.nodes[valueParent].parent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].right) {
                      value = valueParent;
                      rotateLeft(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateRight(self, self.nodes[valueParent].parent);
                }
            } else {
                cursor = self.nodes[self.nodes[valueParent].parent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[valueParent].red = false;
                    self.nodes[cursor].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    value = self.nodes[valueParent].parent;
                } else {
                    if (value == self.nodes[valueParent].left) {
                      value = valueParent;
                      rotateRight(self, value);
                    }
                    valueParent = self.nodes[value].parent;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[valueParent].parent].red = true;
                    rotateLeft(self, self.nodes[valueParent].parent);
                }
            }
        }
        self.nodes[self.root].red = false;
    }
    function replaceParent(Tree storage self, uint a, uint b) private {
        uint bParent = self.nodes[b].parent;
        self.nodes[a].parent = bParent;
        if (bParent == EMPTY) {
            self.root = a;
        } else {
            if (b == self.nodes[bParent].left) {
                self.nodes[bParent].left = a;
            } else {
                self.nodes[bParent].right = a;
            }
        }
    }
    function removeFixup(Tree storage self, uint value) private {
        uint cursor;
        while (value != self.root && !self.nodes[value].red) {
            uint valueParent = self.nodes[value].parent;
            if (value == self.nodes[valueParent].left) {
                cursor = self.nodes[valueParent].right;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateLeft(self, valueParent);
                    cursor = self.nodes[valueParent].right;
                }
                if (!self.nodes[self.nodes[cursor].left].red && !self.nodes[self.nodes[cursor].right].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].right].red) {
                        self.nodes[self.nodes[cursor].left].red = false;
                        self.nodes[cursor].red = true;
                        rotateRight(self, cursor);
                        cursor = self.nodes[valueParent].right;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].right].red = false;
                    rotateLeft(self, valueParent);
                    value = self.root;
                }
            } else {
                cursor = self.nodes[valueParent].left;
                if (self.nodes[cursor].red) {
                    self.nodes[cursor].red = false;
                    self.nodes[valueParent].red = true;
                    rotateRight(self, valueParent);
                    cursor = self.nodes[valueParent].left;
                }
                if (!self.nodes[self.nodes[cursor].right].red && !self.nodes[self.nodes[cursor].left].red) {
                    self.nodes[cursor].red = true;
                    value = valueParent;
                } else {
                    if (!self.nodes[self.nodes[cursor].left].red) {
                        self.nodes[self.nodes[cursor].right].red = false;
                        self.nodes[cursor].red = true;
                        rotateLeft(self, cursor);
                        cursor = self.nodes[valueParent].left;
                    }
                    self.nodes[cursor].red = self.nodes[valueParent].red;
                    self.nodes[valueParent].red = false;
                    self.nodes[self.nodes[cursor].left].red = false;
                    rotateRight(self, valueParent);
                    value = self.root;
                }
            }
        }
        self.nodes[value].red = false;
    }
}

contract RandomNumber {
    using SafeMath for uint256;

    /*
        This gets a random number from 0 to max - 1,
        based on the blockhashes of the previous blockCount blocks.

        If block hash cannot be used, it will fallback ot using 
        most recent block hash.
    */
    function getRandomNumber(
        uint256 max,
        uint256 blockCount,
        uint256 lastBlockNumber) internal view returns (uint256) {

        //The upper bound must be positive
        require(max > 0);
        //The number of blocks to use for entropy must be positive, and less than or equal to 10.
        require(blockCount > 0 && blockCount <= 10);

        /*
            Each successive loop can only add on half as many as previous
    
            For example, if blockCount is 3 and max is 128, then:

            -the earliest block will generate number from 0 to 127
            -the middle block will generate number from 0 to 63
            -the most recent block (lastBlockNumber) will generate number from 0 to 31

            This makes it harder for block validators to manipulate the outcome.
        */

        uint256 divisor = 1;

        uint256 total = 0;

        //Iterate through each block
        for(uint256 blockNumber = lastBlockNumber.sub(blockCount).add(1); blockNumber <= lastBlockNumber; blockNumber = blockNumber.add(1)) {
            bytes32 hash = blockhash(blockNumber);

            //Fall back to using most recent block hash
            if(hash == bytes32(0x0) && lastBlockNumber != block.number.sub(1)) {
                return getRandomNumber(max, blockCount, block.number.sub(1));
            }

            //Convert the hash to a random uint256, mod by max to get it in the range [0, max - 1)
            //then divide by devisor which goes up by powers of 2: 1, 2, 4, 8, etc.
            uint256 randomNumber = (uint256(keccak256(abi.encode(hash))) % max).div(divisor);

            total = total.add(randomNumber);

            divisor = divisor.mul(2);
        }

        return total % max;
    }


}



// SPDX-License-Identifier: Unlicensed

/*
    This contract is used to track the balance of users in a contract.

    It uses the BokkyPooBah library which allows the contract to track
    the top 60% of wallets holding at least 2000 tokens.
*/
contract BalanceTracker is Ownable, HitchensOrderStatisticsTree, RandomNumber {

    using SafeMath for uint256;
    //using HitchensOrderStatisticsTreeLib for HitchensOrderStatisticsTreeLib.Tree;

    //Hardcode in address for the token to track, so balance can be retrieved for a given user.
    IERC20 public stairToken ;

    //Any address in this mapping is not tracked.
    mapping(address => bool) public ineligibleWallets;


    //The tree keeps track of all eligible holders in a tree data structure
    //HitchensOrderStatisticsTreeLib.Tree tree;
    
    //Maps an address to their balance
    mapping(address => uint256) public addressToValue;
    //Keep track of previous balances
    mapping(address => uint256) public addressToValuePrevious;
    //Maps a balance to an anddress
    mapping(uint256 => address) public valueToAddress;


     /*
        The value determins how many of the previous block hashes are used to generate the random number for the lottery payout.

        The lottery will always end at the top of an hour, and so the 8 previous blocks are used to
        generate random numbers.

        To prevent validators from manipulating the tokenHolders array in the last 8 blocks of a lottery,
        any new eligible holders during the last eight blocks of a lottery will always be appended to the end
        of the array, even if there are gaps. Also, those new users will not be eligible to win the for that hour.
    */
    uint256 constant BLOCKS_USED_FOR_ENTROPY = 8;

    constructor(address tokenAddress//tmp to hardcode
                , address teamAddressA//tmp to hardcode
                , address teamAddressB//tmp to hardcode
                , address teamAddressC//tmp to hardcode
                , address presaleAddress//tmp to hardcode
                , address operationsAddress//tmp to hardcode
                , address charityAddress//tmp to hardcode) {
        
        stairToken = IERC20(tokenAddress);
        
        ineligibleWallets[teamAddressA] = true;  //tmp to hardcode
        ineligibleWallets[teamAddressB] = true;  //tmp to hardcode
        ineligibleWallets[teamAddressC] = true;  //tmp to hardcode
        ineligibleWallets[presaleAddress] = true; //tmp to hardcode
        ineligibleWallets[operationsAddress] = true; //tmp to hardcode
        ineligibleWallets[charityAddress] = true; //tmp to hardcode

        ineligibleWallets[tokenAddress] = true;
        ineligibleWallets[address(this)] = true;

    }

    //Makes the msg.sender an ineligible wallet
    //Any lottery contract should call this in their constructor
    function makeSenderIneligible() external {
        ineligibleWallets[msg.sender] = true;

        //Remove from tree if needed
        updateTree(msg.sender, 0);
    }

// to use for pool 
function makeAddressIneligible(address addr) external {
        ineligibleWallets[addr] = true;
        //Remove from tree if needed
        updateTree(addr, 0);
    }
function isAddressIneligible(address addr) external view returns(bool){
    return ineligibleWallets[addr];
}



   

    function treeAbove(uint256 value) public view returns (uint256) {
        return above(tree, value);
    }

    function treeCount() public view returns (uint256) {
        return count(tree);
    }

    function treeValueAtRank(uint256 rank) public view returns (uint256) {
        return atRank(tree, rank);
    }

    function treeAtPercentile(uint256 percentile) public view returns (uint256) {
        return atPercentile(tree, percentile);
    }

    function treeRankForValue(uint256 value) public view returns (uint256) {
        return rank(tree, value);
    }
    
    function treeInsert(uint256 value) internal {
        insert(tree, bytes32(0x0), value);
    }

    function treeRemove(uint256 value) internal {
        remove(tree, bytes32(0x0), value);
    }


    /*
        Updates the red-black tree for new balance for user.
    */
    function updateTree(address user, uint256 _balance) public {

        uint256 existing = addressToValue[user];

        addressToValuePrevious[user] = existing;

        if(_balance == existing) {
            return;
        }

        if(existing > 0) {
            valueToAddress[existing] = address(0x0);
            treeRemove(existing);
        }

        //Only bother with users with a non-trivial balance
        //so that we can safely store them if they match other users' balances
        //modify stairToken
        if(_balance > 1 * (2000 ** stairToken.decimals())) {
            //Make sure the spot isn't taken

            uint256 iterations = 0;

            while(valueToAddress[_balance] != address(0x0)) {
                //Impossible to go to 0 due to token having 18 decimals
                iterations = iterations.add(1);

                //Randomly decrease to speed it up
                uint256 randomAmount = getRandomNumber(iterations, 1, block.number - 1);
                _balance = _balance.sub(randomAmount);
            }

            valueToAddress[_balance] = user;
            addressToValue[user] = _balance;

            treeInsert(_balance);
        }
        else
        {
            addressToValue[user] = 0;
        }

    }

    //Alows anyone to call this to update the tree
    //based on a user's current balance
    function updateUserBalance(address user) external {
        handleAddressBalanceUpdated(user, stairToken.balanceOf(user));
    }

    //Updates the tree if the user is eligilble
    function handleAddressBalanceUpdated(
        address user,
        uint256 balance) internal {


        //If the wallet is not eligible, then they cannot be added to the data structures
        //and therefore cannot win
        if(ineligibleWallets[user]) {
            return;
        }

        //Call this to update the tree that contains
        //sorted structor of all token holders
        updateTree(user, balance);
    }

    //Gets a user at a given rank, which is 
    //from 1 to count, in ascending order
    function getUserAtRank(uint256 rank)
        public view returns (address) {
        return valueToAddress[treeValueAtRank(rank)];
    }

    //Returns the rank of a given user, or 0 if not found
    function getRankForUser(address user)
        public view returns (uint256) {
        uint256 value = addressToValue[user];

        //Make sure user is in the tree
        if(value == 0) {
            return 0;
        }

        return treeRankForValue(value);
    }

   
}