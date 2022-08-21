// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./approve.sol";

contract swap {
    /// @dev defining the struct to contain all the details of a particular order

    struct tokenDetails {
        address to;
        uint amountOfTokensIn;
        uint amountOfTokensOut;
        address addressIn;
        address addressOut;
        bool excuted;
        bool terminated;
    }

    /// @dev custom errors

    /// didn't order
    error DidntOrder();

    /// terminated before
    error terminatedBefore();

    /// @dev an array of structs
    tokenDetails[] alldetails;

    /// @dev all events

    event placeOrdered(
        address indexed _to,
        address indexed _addressIn,
        address indexed _addressOut,
        uint _amountOfTokensIn,
        uint _amountOfTokensOut
    );

    event terminated(address to, uint amount);

    event excuted(address indexed _to, address addressOut, uint amount);

    function placeOrder(
        address _addressIn,
        address _addressOut,
        uint _amountOfTokensIn,
        uint _amountOfTokensOut
    ) external returns (bool) {
        tokenDetails memory TD = tokenDetails(
            msg.sender,
            _amountOfTokensIn,
            _amountOfTokensOut,
            _addressIn,
            _addressOut,
            false,
            false
        );
        alldetails.push(TD);

        bool transferToContract = IERC20(_addressIn).transferFrom(
            msg.sender,
            address(this),
            _amountOfTokensIn
        );

        emit placeOrdered(
            msg.sender,
            _addressIn,
            _addressOut,
            _amountOfTokensIn,
            _amountOfTokensOut
        );

        return transferToContract;
    }

    function terminate(uint orderIndex) external {
        tokenDetails memory TD = alldetails[orderIndex];
        if (TD.to != msg.sender) {
            revert DidntOrder();
        }

        if (TD.terminated == true) {
            revert terminatedBefore();
        }

        TD.terminated == true;

        IERC20(TD.addressIn).transfer(msg.sender, TD.amountOfTokensIn);

        emit terminated(msg.sender, TD.amountOfTokensIn);
    }

    function peek(
        address _addressIn,
        address _addressOut,
        uint _amountOfTokensIn,
        uint _amountOfTokensOut
    ) external view returns (int) {
        int defaultID = -1;
        for (uint i = 0; i < alldetails.length; i++) {
            if (
                _addressIn == alldetails[i].addressOut &&
                _addressOut == alldetails[i].addressIn &&
                _amountOfTokensIn == alldetails[i].amountOfTokensOut &&
                _amountOfTokensOut <= alldetails[i].amountOfTokensIn
            ) {
                defaultID = int(i);
                break;
            }
        }
        return defaultID;
    }

    function excuteOrder(uint index) external {
        tokenDetails memory TD = alldetails[index];
        require(TD.terminated != true, "he terminated it");
        IERC20(TD.addressOut).transferFrom(
            msg.sender,
            TD.to,
            TD.amountOfTokensOut
        );
        IERC20(TD.addressIn).transfer(msg.sender, TD.amountOfTokensIn);

        emit excuted(msg.sender, TD.addressIn, TD.amountOfTokensIn);
        emit excuted(TD.to, TD.addressOut, TD.amountOfTokensOut);
    }
}
