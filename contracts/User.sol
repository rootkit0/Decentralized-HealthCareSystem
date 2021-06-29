//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

contract User {
    address private admin;
    constructor() {
        //All users admins for testing purposes
        //For final version set specific addresses
        admin = msg.sender;
    }

    struct UserModel {
        address userId;
        string userRole;
        string idCardNumber;
        string healthCardId;
        string passwordHash;
    }
    mapping(address => UserModel) userList;

	function registerUser(string memory idCardNumber, string memory healthCardId, string memory passwordHash) public {
        //Check that user doesn't exists
        require(userList[msg.sender].userId == address(0));
        //Check idCardNumber and healthCardId format
        require(validateIdCardNumber(idCardNumber) == true);
        require(validateHealthCardId(healthCardId) == true);
        //Assuming: Check in government DB that idCardNumber and healthCardId matches
        //Register the user
        address userId = msg.sender;
        userList[userId].userId = userId;
        if(userId == admin) {
            userList[userId].userRole = "admin";
        }
        else {
            //Default user role is patient
            //Only admins can upgrade roles
            userList[userId].userRole = "patient";
        }
        userList[userId].idCardNumber = idCardNumber;
        userList[userId].healthCardId = healthCardId;
        userList[userId].passwordHash = passwordHash;
	}

    function getPasswordHash(string memory idCardNumber, string memory healthCardId) public view returns(string memory) {
        //Check that user exists
        require(userList[msg.sender].userId != address(0));
        //Compare given ids with ones associated with user account
        require(compareStrings(userList[msg.sender].idCardNumber, idCardNumber));
        require(compareStrings(userList[msg.sender].healthCardId, healthCardId));
        return userList[msg.sender].passwordHash;
	}

    function updateUserPassword(string memory idCardNumber, string memory healthCardId, string memory oldPasswordHash, string memory newPasswordHash) public {
        //Check that user exists
        require(userList[msg.sender].userId != address(0));
        //Compare given ids with ones associated with user account
        require(compareStrings(userList[msg.sender].idCardNumber, idCardNumber));
        require(compareStrings(userList[msg.sender].healthCardId, healthCardId));
        //Check old password match
        require(compareStrings(userList[msg.sender].passwordHash, oldPasswordHash));
        //Update password
        userList[msg.sender].passwordHash = newPasswordHash;
    }

    function getUserRole() public view returns(string memory){
        require(userList[msg.sender].userId != address(0));
        return userList[msg.sender].userRole;
    }

    function updateUserRole(address userId, string memory userRole) public {
        require(compareStrings(userList[msg.sender].userRole, "admin"));
        require(userList[userId].userId != address(0));
        userList[userId].userRole = userRole;
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

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
