//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;

contract AuthContract {
    mapping(address => bool) private admins;
    constructor() public {
        //All users admins for testing purposes
        //For final version set specific addresses
        admins[msg.sender] = true;
    }
    function isAdmin() public view returns(bool) {
        return admins[msg.sender];
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
        address userId = msg.sender;
        userList[userId].userId = userId;
        if(isAdmin()) {
            userList[userId].userRole = "admin";
        }
        else {
            //Default user role is patient (only admins can upgrade user roles)
            userList[userId].userRole = "patient";
        }
        userList[userId].idCardNumber = idCardNumber;
        userList[userId].healthCardId = healthCardId;
        userList[userId].passwordHash = passwordHash;
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

    function updateUserPassword(address userId, string memory oldPasswordHash, string memory newPasswordHash) public returns(bool) {
        //Check that user exists
        require(userList[userId].userId != address(0), "User don't exists!");
        //Verify input parameters
        require(compareStrings(userList[userId].passwordHash, oldPasswordHash), "Passwords don't match!");
        //Update password
        userList[userId].passwordHash = newPasswordHash;
        return true;
    }

    function getUserRole() public view returns(string memory) {
        //Check that user exists
        require(userList[msg.sender].userId != address(0), "User don't exists!");
        return userList[msg.sender].userRole;
    }

    function updateUserRole(address userId, string memory userRole) public returns(bool) {
        //Check that user exists
        require(userList[userId].userId != address(0), "User don't exists!");
        //Update user role
        userList[userId].userRole = userRole;
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

    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
}
