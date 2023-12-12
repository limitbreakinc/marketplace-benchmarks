// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import { BaseMarketConfig } from "../../BaseMarketConfig.sol";
import "../../Types.sol";
import { IPaymentProcessorV2 } from "./interfaces/IPaymentProcessorV2.sol";
import { IPaymentProcessorEncoder } from "./interfaces/IPaymentProcessorEncoder.sol";
import "./interfaces/Constants.sol";
import "./interfaces/PaymentProcessorDataTypesV2.sol";
import "forge-std/Test.sol";
import { ECDSA } from "./lib/ECDSA.sol";
import { TestERC721 } from "test/tokens/TestERC721.sol";

contract PaymentProcessorV2Config is BaseMarketConfig, Test {
    IPaymentProcessorEncoder internal encoder =
        IPaymentProcessorEncoder(address(0x000000fBBCe9e76C8a3D8b1a3ecB7e65C5474470));

    IPaymentProcessorV2 paymentProcessor =
        IPaymentProcessorV2(address(0x6B1553C3c9B443cbcD2697540a305d512EEf3098));
    mapping(address => uint256) internal _nonces;

    function name() external pure override returns (string memory) {
        return "Payment Processor V2";
    }

    function market() public view override returns (address) {
        return address(paymentProcessor);
    }

    function beforeAllPrepareMarketplace(address seller, address buyer) external override {
        buyerNftApprovalTarget = sellerNftApprovalTarget = buyerErc20ApprovalTarget = sellerErc20ApprovalTarget = address(
            paymentProcessor
        );
    }

     function beforeAllPrepareMarketplaceCollections(address test721_1, address test1155_1) external override {
         vm.startPrank(address(test721_1));
        paymentProcessor.setCollectionPaymentSettings(
            encoder.encodeSetCollectionPaymentSettingsCalldata(
                address(paymentProcessor), 
                address(test721_1), 
                PaymentSettings.AllowAnyPaymentMethod, 
                0, 
                address(0), 
                0, 
                address(0), 
                0, 
                address(0), 
                false
            )
        );
        vm.stopPrank();

        vm.startPrank(address(test1155_1));
        paymentProcessor.setCollectionPaymentSettings(
            encoder.encodeSetCollectionPaymentSettingsCalldata(
                address(paymentProcessor), 
                address(test1155_1), 
                PaymentSettings.AllowAnyPaymentMethod, 
                0, 
                address(0), 
                0, 
                address(0), 
                0, 
                address(0), 
                false
            )
        );
        vm.stopPrank();
     }

    function getPayload_BuyOfferedERC721WithEther(
        TestOrderContext calldata context,
        TestItem721 calldata nft,
        uint256 ethAmount
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: ethAmount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            ethAmount,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC1155WithEther(
        TestOrderContext calldata context,
        TestItem1155 calldata nft,
        uint256 ethAmount
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC1155_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: uint248(nft.amount),
                itemPrice: ethAmount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: uint248(nft.amount),
                minimumFillAmount: uint248(nft.amount)
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            ethAmount,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC721WithERC20(
        TestOrderContext calldata context,
        TestItem721 calldata nft,
        TestItem20 calldata erc20
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC721WithWETH(
        TestOrderContext calldata context,
        TestItem721 memory nft,
        TestItem20 memory erc20
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC1155WithERC20(
        TestOrderContext calldata context,
        TestItem1155 calldata nft,
        TestItem20 memory erc20
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }
        
        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC1155_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: uint248(nft.amount),
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: uint248(nft.amount),
                minimumFillAmount: uint248(nft.amount)
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC20WithERC721(
        TestOrderContext calldata context,
        TestItem20 memory erc20,
        TestItem721 memory nft
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.offerer,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _acceptItemOffer(saleDetails)
        );
    }

    function getPayload_BuyOfferedWETHWithERC721(
        TestOrderContext calldata context,
        TestItem20 memory erc20,
        TestItem721 memory nft
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.offerer,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _acceptItemOffer(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC20WithERC1155(
        TestOrderContext calldata context,
        TestItem20 memory erc20,
        TestItem1155 memory nft
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC1155_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.offerer,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20.token,
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: uint248(nft.amount),
                itemPrice: erc20.amount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: uint248(nft.amount),
                minimumFillAmount: uint248(nft.amount)
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _acceptItemOffer(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC721WithEtherOneFeeRecipient(
        TestOrderContext calldata context,
        TestItem721 memory nft,
        uint256 priceEthAmount,
        address feeRecipient,
        uint256 feeEthAmount
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        uint256 ethAmount = priceEthAmount + feeEthAmount;
        uint256 feeRate = (feeEthAmount * 10000) / priceEthAmount;

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: feeRecipient,
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: ethAmount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: feeRate,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            ethAmount,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedERC721WithEtherTwoFeeRecipient(
        TestOrderContext calldata context,
        TestItem721 memory nft,
        uint256 priceEthAmount,
        address feeRecipient1,
        uint256 feeEthAmount1,
        address feeRecipient2,
        uint256 feeEthAmount2
    ) external override returns (TestOrderPayload memory execution) {
        if (context.listOnChain) {
            _notImplemented();
        }

        uint256 ethAmount = priceEthAmount + feeEthAmount1 + feeEthAmount2;
        uint256 feeRate1 = (feeEthAmount1 * 10000) / priceEthAmount;
        uint256 feeRate2 = (feeEthAmount2 * 10000) / priceEthAmount;

        TestERC721(nft.token).setTokenRoyalty(
            nft.identifier,
            feeRecipient2,
            uint96(feeRate2)
        );

        Order memory saleDetails = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: context.offerer,
                beneficiary: context.fulfiller,
                marketplace: feeRecipient1,
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nft.token,
                tokenId: nft.identifier,
                amount: 1,
                itemPrice: ethAmount,
                nonce: _getNextNonce(context.offerer),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: feeRate1,
                maxRoyaltyFeeNumerator: feeRate2,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            ethAmount,
            _buySignedListing(saleDetails)
        );
    }

    function getPayload_BuyOfferedManyERC721WithEtherDistinctOrders(
        TestOrderContext[] calldata contexts,
        TestItem721[] calldata nfts,
        uint256[] calldata ethAmounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        uint256 totalEthAmount = 0;
        for (uint256 i = 0; i < nfts.length; ++i) {
            totalEthAmount += ethAmounts[i];
        }

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nfts[i].token,
                tokenId: nfts[i].identifier,
                amount: 1,
                itemPrice: ethAmounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            totalEthAmount,
            _bulkBuySignedListings(saleDetailsArray)
        );
    }

    function getPayload_BuyOfferedManyERC721WithErc20DistinctOrders(
        TestOrderContext[] calldata contexts,
        address erc20Address,
        TestItem721[] calldata nfts,
        uint256[] calldata erc20Amounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20Address,
                tokenAddress: nfts[i].token,
                tokenId: nfts[i].identifier,
                amount: 1,
                itemPrice: erc20Amounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _bulkBuySignedListings(saleDetailsArray)
        );
    }

    function getPayload_BuyOfferedManyERC721WithWETHDistinctOrders(
        TestOrderContext[] calldata contexts,
        address erc20Address,
        TestItem721[] calldata nfts,
        uint256[] calldata erc20Amounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20Address,
                tokenAddress: nfts[i].token,
                tokenId: nfts[i].identifier,
                amount: 1,
                itemPrice: erc20Amounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _bulkBuySignedListings(saleDetailsArray)
        );
    }

    function getPayload_SweepERC721CollectionWithEther(
        TestOrderContext[] calldata contexts,
        TestItem721[] calldata nfts,
        uint256[] calldata ethAmounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        uint256 totalEthAmount = 0;
        uint256 numItemsInBundle = nfts.length;
        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        vm.startPrank(alice);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(alice)));
        vm.stopPrank();

        vm.startPrank(bob);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(bob)));
        vm.stopPrank();

        for (uint256 i = 0; i < numItemsInBundle; ++i) {
            totalEthAmount += ethAmounts[i];
        }

        SweepOrder memory sweepOrder = SweepOrder({
            protocol: OrderProtocols.ERC721_FILL_OR_KILL,
            tokenAddress: nfts[0].token,
            paymentMethod: address(0),
            beneficiary: bob
        });

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: address(0),
                tokenAddress: nfts[0].token,
                tokenId: i + 1,
                amount: 1,
                itemPrice: ethAmounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            totalEthAmount,
            _sweepSignedListings(sweepOrder, saleDetailsArray)
        );
    }

    function getPayload_SweepERC721CollectionWithErc20(
        TestOrderContext[] calldata contexts,
        address erc20Address,
        TestItem721[] calldata nfts,
        uint256[] calldata erc20Amounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        uint256 totalErc20Amount = 0;
        uint256 numItemsInBundle = nfts.length;
        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        vm.startPrank(alice);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(alice)));
        vm.stopPrank();

        vm.startPrank(bob);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(bob)));
        vm.stopPrank();

        for (uint256 i = 0; i < numItemsInBundle; ++i) {
            totalErc20Amount += erc20Amounts[i];
        }

        SweepOrder memory sweepOrder = SweepOrder({
            protocol: OrderProtocols.ERC721_FILL_OR_KILL,
            tokenAddress: nfts[0].token,
            paymentMethod: erc20Address,
            beneficiary: bob
        });

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20Address,
                tokenAddress: nfts[0].token,
                tokenId: i + 1,
                amount: 1,
                itemPrice: erc20Amounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _sweepSignedListings(sweepOrder, saleDetailsArray)
        );
    }

    function getPayload_SweepERC721CollectionWithWETH(
        TestOrderContext[] calldata contexts,
        address erc20Address,
        TestItem721[] calldata nfts,
        uint256[] calldata erc20Amounts
    ) external override returns (TestOrderPayload memory execution) {
        for (uint256 i = 0; i < contexts.length; ++i) {
            if (contexts[i].listOnChain) {
                _notImplemented();
            }
        }

        uint256 totalErc20Amount = 0;
        uint256 numItemsInBundle = nfts.length;
        address alice = contexts[0].offerer;
        address bob = contexts[0].fulfiller;

        vm.startPrank(alice);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(alice)));
        vm.stopPrank();

        vm.startPrank(bob);
        paymentProcessor.revokeSingleNonce(encoder.encodeRevokeSingleNonceCalldata(address(paymentProcessor), _getNextNonce(bob)));
        vm.stopPrank();

        for (uint256 i = 0; i < numItemsInBundle; ++i) {
            totalErc20Amount += erc20Amounts[i];
        }

        SweepOrder memory sweepOrder = SweepOrder({
            protocol: OrderProtocols.ERC721_FILL_OR_KILL,
            tokenAddress: nfts[0].token,
            paymentMethod: erc20Address,
            beneficiary: bob
        });

        Order[] memory saleDetailsArray = new Order[](nfts.length);
        for (uint256 i = 0; i < nfts.length; ++i) {
            saleDetailsArray[i] = Order({
                protocol: OrderProtocols.ERC721_FILL_OR_KILL,
                maker: alice,
                beneficiary: bob,
                marketplace: address(0),
                fallbackRoyaltyRecipient: address(0),
                paymentMethod: erc20Address,
                tokenAddress: nfts[0].token,
                tokenId: i + 1,
                amount: 1,
                itemPrice: erc20Amounts[i],
                nonce: _getNextNonce(alice),
                expiration: type(uint256).max,
                marketplaceFeeNumerator: 0,
                maxRoyaltyFeeNumerator: 0,
                requestedFillAmount: 1,
                minimumFillAmount: 1
            });
        }

        execution.executeOrder = TestCallParameters(
            address(paymentProcessor),
            0,
            _sweepSignedListings(sweepOrder, saleDetailsArray)
        );
    }

    function _getNextNonce(address account) internal returns (uint256) {
        uint256 nextUnusedNonce = _nonces[account];
        ++_nonces[account];
        return nextUnusedNonce;
    }

    function _buySignedListing(Order memory saleDetails) internal view returns (bytes memory) {
        return
            abi.encodeWithSelector(
                IPaymentProcessorV2.buyListing.selector, 
                encoder.encodeBuyListingCalldata(
                    address(paymentProcessor), 
                    saleDetails, 
                    _getSignedSaleApproval(saleDetails),
                    Cosignature({signer: address(0), taker: address(0), expiration: 0, v: 0, r: bytes32(0), s: bytes32(0)}),
                    FeeOnTop({recipient: address(0), amount: 0})
                )
            );
    }

    function _bulkBuySignedListings(Order[] memory saleDetailsArray) internal view returns (bytes memory) {
        SignatureECDSA[] memory sellerSignaturesArray = new SignatureECDSA[](saleDetailsArray.length);
        Cosignature[] memory cosignatures = new Cosignature[](saleDetailsArray.length);
        FeeOnTop[] memory feesOnTop = new FeeOnTop[](saleDetailsArray.length);

        for (uint256 i = 0; i < saleDetailsArray.length; ++i) {
            sellerSignaturesArray[i] = _getSignedSaleApproval(saleDetailsArray[i]);
            cosignatures[i] = Cosignature({signer: address(0), taker: address(0), expiration: 0, v: 0, r: bytes32(0), s: bytes32(0)});
            feesOnTop[i] = FeeOnTop({recipient: address(0), amount: 0});
        }

        return 
            abi.encodeWithSelector(
                IPaymentProcessorV2.bulkBuyListings.selector, 
                encoder.encodeBulkBuyListingsCalldata(
                address(paymentProcessor), 
                saleDetailsArray, 
                sellerSignaturesArray,
                cosignatures,
                feesOnTop
            )
        );
    }

    function _sweepSignedListings(SweepOrder memory sweepOrder, Order[] memory saleDetailsArray) internal view returns (bytes memory) {
        SignatureECDSA[] memory sellerSignaturesArray = new SignatureECDSA[](saleDetailsArray.length);
        SweepItem[] memory sweepItems = new SweepItem[](saleDetailsArray.length);
        Cosignature[] memory cosignatures = new Cosignature[](saleDetailsArray.length);
        FeeOnTop memory feeOnTop = FeeOnTop({recipient: address(0), amount: 0});

        for (uint256 i = 0; i < saleDetailsArray.length; ++i) {
            sellerSignaturesArray[i] = _getSignedSaleApproval(saleDetailsArray[i]);
            sweepItems[i] = SweepItem({
                maker: saleDetailsArray[i].maker,
                marketplace: saleDetailsArray[i].marketplace,
                fallbackRoyaltyRecipient: saleDetailsArray[i].fallbackRoyaltyRecipient,
                tokenId: saleDetailsArray[i].tokenId,
                amount: saleDetailsArray[i].amount,
                itemPrice: saleDetailsArray[i].itemPrice,
                nonce: saleDetailsArray[i].nonce,
                expiration: saleDetailsArray[i].expiration,
                marketplaceFeeNumerator: saleDetailsArray[i].marketplaceFeeNumerator,
                maxRoyaltyFeeNumerator: saleDetailsArray[i].maxRoyaltyFeeNumerator
            });
            cosignatures[i] = Cosignature({signer: address(0), taker: address(0), expiration: 0, v: 0, r: bytes32(0), s: bytes32(0)});
        }

        return 
            abi.encodeWithSelector(
                IPaymentProcessorV2.sweepCollection.selector, 
                encoder.encodeSweepCollectionCalldata(
                    address(paymentProcessor), 
                    feeOnTop,
                    sweepOrder,
                    sweepItems, 
                    sellerSignaturesArray,
                    cosignatures
            )
        );
    }

    function _getSignedSaleApproval(Order memory saleDetails) internal view returns (SignatureECDSA memory signedListing) {
        (signedListing,) = _getSignedSaleApprovalAndDigest(saleDetails);
    }

    function _getSignedSaleApprovalAndDigest(Order memory saleDetails) internal view returns (SignatureECDSA memory signedListing, bytes32 digest) {
        digest = 
            ECDSA.toTypedDataHash(
                paymentProcessor.getDomainSeparator(), 
                keccak256(
                    bytes.concat(
                        abi.encode(
                            SALE_APPROVAL_HASH,
                            uint8(saleDetails.protocol),
                            address(0),
                            saleDetails.maker,
                            saleDetails.marketplace,
                            saleDetails.fallbackRoyaltyRecipient,
                            saleDetails.paymentMethod,
                            saleDetails.tokenAddress,
                            saleDetails.tokenId
                        ),
                        abi.encode(
                            saleDetails.amount,
                            saleDetails.itemPrice,
                            saleDetails.expiration,
                            saleDetails.marketplaceFeeNumerator,
                            saleDetails.maxRoyaltyFeeNumerator,
                            saleDetails.nonce,
                            paymentProcessor.masterNonces(saleDetails.maker)
                        )
                    )
                )
            );

        (uint8 listingV, bytes32 listingR, bytes32 listingS) = _sign(saleDetails.maker, digest);
        signedListing = SignatureECDSA({v: listingV, r: listingR, s: listingS});
    }

    function _acceptItemOffer(Order memory saleDetails) internal view returns (bytes memory) {
        return
            abi.encodeWithSelector(
                IPaymentProcessorV2.acceptOffer.selector, 
                encoder.encodeAcceptOfferCalldata(
                    address(paymentProcessor), 
                    false,
                    saleDetails, 
                    _getSignedItemOffer(saleDetails),
                    TokenSetProof({
                        rootHash: bytes32(0),
                        proof: new bytes32[](0)
                    }),
                    Cosignature({signer: address(0), taker: address(0), expiration: 0, v: 0, r: bytes32(0), s: bytes32(0)}),
                    FeeOnTop({recipient: address(0), amount: 0})
                )
            );
    }

    function _getSignedItemOffer(Order memory saleDetails) internal view returns (SignatureECDSA memory signedOffer) {
        bytes32 offerDigest = 
            ECDSA.toTypedDataHash(
                paymentProcessor.getDomainSeparator(), 
                keccak256(
                    bytes.concat(
                        abi.encode(
                            ITEM_OFFER_APPROVAL_HASH,
                            uint8(saleDetails.protocol),
                            address(0),
                            saleDetails.maker,
                            saleDetails.beneficiary,
                            saleDetails.marketplace,
                            saleDetails.fallbackRoyaltyRecipient,
                            saleDetails.paymentMethod,
                            saleDetails.tokenAddress
                        ),
                        abi.encode(
                            saleDetails.tokenId,
                            saleDetails.amount,
                            saleDetails.itemPrice,
                            saleDetails.expiration,
                            saleDetails.marketplaceFeeNumerator,
                            saleDetails.nonce,
                            paymentProcessor.masterNonces(saleDetails.maker)
                        )
                    )
                )
            );
    
        (uint8 offerV, bytes32 offerR, bytes32 offerS) = _sign(saleDetails.maker, offerDigest);
        signedOffer = SignatureECDSA({v: offerV, r: offerR, s: offerS});
    }
}
