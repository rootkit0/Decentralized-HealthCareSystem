//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract AuthContract {
    constructor() public { }
    function isAdmin() public view returns(bool) {
        //All users admins for testing purposes
        //For final version set specific addresses
        return true;
    }

    struct UserModel {
        address userId;
        string userRole;
        string idCardNumber;
        string healthCardId;
        string passwordHash;
    }
    mapping(address => UserModel) private userList;

	function signupUser(string memory idCardNumber, string memory healthCardId, string memory passwordHash) public returns(bool) {
        //Check that user don't exists
        require(userList[msg.sender].userId == address(0), "User already exists!");
        //Check idCardNumber and healthCardId formats
        require(validateIdCardNumber(idCardNumber) == true, "Wrong ID Card Number format");
        require(validateHealthCardId(healthCardId) == true, "Wrong HealthCardID format");
        //Register the user
        userList[msg.sender].userId = msg.sender;
        if(isAdmin()) {
            userList[msg.sender].userRole = "admin";
        }
        else {
            userList[msg.sender].userRole = "patient";
        }
        userList[msg.sender].idCardNumber = idCardNumber;
        userList[msg.sender].healthCardId = healthCardId;
        userList[msg.sender].passwordHash = passwordHash;
        return true;
	}

    function loginUser(string memory idCardNumber, string memory healthCardId, string memory passwordHash) public view returns(bool) {
        //Check that user exists
        require(userList[msg.sender].userId != address(0), "User don't exists!");
        //Verify input parameters
        require(compareStrings(userList[msg.sender].idCardNumber, idCardNumber), "ID Card Number don't match!");
        require(compareStrings(userList[msg.sender].healthCardId, healthCardId), "HealthCardId don't match!");
        require(compareStrings(userList[msg.sender].passwordHash, passwordHash), "Passwords don't match!");
        return true;
    }

    function updateUserPassword(string memory oldPasswordHash, string memory newPasswordHash) public returns(bool) {
        //Check that user exists
        require(userList[msg.sender].userId != address(0), "User don't exists!");
        //Verify old password matches
        require(compareStrings(userList[msg.sender].passwordHash, oldPasswordHash), "Passwords don't match!");
        //Update password
        userList[msg.sender].passwordHash = newPasswordHash;
        return true;
    }

    function getUserRole() public view returns(string memory) {
        //Check that user exists
        require(userList[msg.sender].userId != address(0), "User don't exists!");
        return userList[msg.sender].userRole;
    }

    function updateUserRole(string memory userId, string memory newUserRole) public returns(bool) {
        //Parse given string to address
        address userIdAddr = parseAddr(userId);
        //Check that user exists
        require(userList[userIdAddr].userId != address(0), "User don't exists!");
        //Update user role
        userList[userIdAddr].userRole = newUserRole;
        return true;
    }

    function validateIdCardNumber(string memory idCardNumber) private pure returns(bool) {            
        bytes memory cnId = bytes(idCardNumber);
        if(cnId.length == 9) {
            for(uint256 i=0; i < cnId.length; ++i) {
                bytes1 char = cnId[i];
                if(i < 8 && !(char >= 0x30 && char <= 0x39)) {
                    //Not number, wrong format
                    return false;
                }
                if(i == 8 && !(char >= 0x41 && char <= 0x5A) && !(char >= 0x41 && char <= 0x5A)) {
                    //Not character, wrong format
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    function validateHealthCardId(string memory healthCardId) private pure returns (bool) {
        bytes memory hcId = bytes(healthCardId);
        if(hcId.length == 14) {
            for(uint256 i=0; i<hcId.length; ++i) {
                bytes1 char = hcId[i];
                if(i <= 3 && !(char >= 0x41 && char <= 0x5A) && !(char >= 0x41 && char <= 0x5A)) {
                    //Not character, wrong format
                    return false;
                }
                if(i > 3 && !(char >= 0x30 && char <= 0x39)) {
                    //Not number, wrong format
                    return false;
                }
            }
            return true;
        }
        return false;
    }

    function parseAddr(string memory _a) private pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
