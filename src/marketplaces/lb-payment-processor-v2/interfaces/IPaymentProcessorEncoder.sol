// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./PaymentProcessorDataTypesV2.sol";

/**
 * @title IPaymentProcessorEncoder
 * @author Limit Break, Inc.
 * @notice Interface definition for payment processor encoder contracts.
 */
interface IPaymentProcessorEncoder {
    function encodeCreatePaymentMethodWhitelistCalldata(address paymentProcessorAddress, string calldata whitelistName) external view returns (bytes memory);
    function encodeWhitelistPaymentMethodCalldata(address paymentProcessorAddress, uint32 paymentMethodWhitelistId, address paymentMethod) external view returns (bytes memory);
    function encodeUnwhitelistPaymentMethodCalldata(address paymentProcessorAddress, uint32 paymentMethodWhitelistId, address paymentMethod) external view returns (bytes memory);

    function encodeSetCollectionPaymentSettingsCalldata(
        address paymentProcessorAddress, 
        address tokenAddress, 
        PaymentSettings paymentSettings,
        uint32 paymentMethodWhitelistId,
        address constrainedPricingPaymentMethod,
        uint16 royaltyBackfillNumerator,
        address royaltyBackfillReceiver,
        uint16 royaltyBountyNumerator,
        address exclusiveBountyReceiver,
        bool blockTradesFromUntrustedChannels
    ) external view returns (bytes memory);

    function encodeSetCollectionPricingBoundsCalldata(
        address paymentProcessorAddress, 
        address tokenAddress, 
        PricingBounds calldata pricingBounds
    ) external view returns (bytes memory);

    function encodeSetTokenPricingBoundsCalldata(
        address paymentProcessorAddress, 
        address tokenAddress, 
        uint256[] calldata tokenIds, 
        PricingBounds[] calldata pricingBounds
    ) external view returns (bytes memory);

    function encodeAddTrustedChannelForCollectionCalldata(address paymentProcessorAddress, address tokenAddress, address channel) external view returns (bytes memory);
    function encodeRemoveTrustedChannelForCollectionCalldata(address paymentProcessorAddress, address tokenAddress, address channel) external view returns (bytes memory);

    function encodeRevokeSingleNonceCalldata(address paymentProcessorAddress, uint256 nonce) external view returns (bytes memory);
    function encodeRevokeOrderDigestCalldata(address paymentProcessorAddress, bytes32 digest) external view returns (bytes memory);

    function encodeBuyListingCalldata(
        address paymentProcessorAddress, 
        Order memory saleDetails, 
        SignatureECDSA memory signature,
        Cosignature memory cosignature,
        FeeOnTop memory feeOnTop
    ) external view returns (bytes memory);

    function encodeAcceptOfferCalldata(
        address paymentProcessorAddress, 
        bool isCollectionLevelOffer,
        Order memory saleDetails, 
        SignatureECDSA memory signature,
        TokenSetProof memory tokenSetProof,
        Cosignature memory cosignature,
        FeeOnTop memory feeOnTop
    ) external view returns (bytes memory);

    function encodeBulkBuyListingsCalldata(
        address paymentProcessorAddress, 
        Order[] calldata saleDetailsArray, 
        SignatureECDSA[] calldata signatures,
        Cosignature[] calldata cosignatures,
        FeeOnTop[] calldata feesOnTop
    ) external view returns (bytes memory);

    function encodeBulkAcceptOffersCalldata(
        address paymentProcessorAddress, 
        bool[] memory isCollectionLevelOfferArray,
        Order[] memory saleDetailsArray,
        SignatureECDSA[] memory signatures,
        TokenSetProof[] memory tokenSetProofsArray,
        Cosignature[] memory cosignaturesArray,
        FeeOnTop[] memory feesOnTopArray
    ) external view returns (bytes memory);

    function encodeSweepCollectionCalldata(
        address paymentProcessorAddress, 
        FeeOnTop memory feeOnTop,
        SweepOrder memory sweepOrder,
        SweepItem[] calldata items,
        SignatureECDSA[] calldata signatures,
        Cosignature[] calldata cosignatures
    ) external view returns (bytes memory);
}
