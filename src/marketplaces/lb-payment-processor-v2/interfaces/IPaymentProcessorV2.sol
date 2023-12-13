// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

import "./PaymentProcessorDataTypesV2.sol";

/**
 * @title IPaymentProcessorV2
 * @author Limit Break, Inc.
 * @notice Interface definition for payment processor contracts.
 */
interface IPaymentProcessorV2 {
    event BuyListingERC721(
        address indexed buyer,
        address indexed seller,
        address indexed tokenAddress,
        address beneficiary,
        address paymentCoin,
        uint256 tokenId,
        uint256 salePrice);

    event BuyListingERC1155(
        address indexed buyer,
        address indexed seller,
        address indexed tokenAddress,
        address beneficiary,
        address paymentCoin,
        uint256 tokenId,
        uint256 amount,
        uint256 salePrice);

    event AcceptOfferERC721(
        address indexed seller,
        address indexed buyer,
        address indexed tokenAddress,
        address beneficiary,
        address paymentCoin,
        uint256 tokenId,
        uint256 salePrice);

    event AcceptOfferERC1155(
        address indexed seller,
        address indexed buyer,
        address indexed tokenAddress,
        address beneficiary,
        address paymentCoin,
        uint256 tokenId,
        uint256 amount,
        uint256 salePrice);

    event CreatedPaymentMethodWhitelist(
        uint32 indexed paymentMethodWhitelistId, 
        address indexed whitelistOwner,
        string whitelistName);

    /// @notice Emitted when a user revokes all of their existing listings or offers that share the master nonce.
    event MasterNonceInvalidated(address indexed account, uint256 nonce);

    /// @notice Emitted when a user revokes a single listing or offer nonce for a specific marketplace.
    event NonceInvalidated(
        uint256 indexed nonce, 
        address indexed account, 
        bool wasCancellation);

    /// @notice Emitted when a user revokes a single listing or offer nonce for a specific marketplace.
    event OrderDigestInvalidated(
        bytes32 indexed orderDigest, 
        address indexed account, 
        bool wasCancellation);

    /// @notice Emitted when a coin is added to the approved coins mapping for a security policy
    event PaymentMethodAddedToWhitelist(
        uint32 indexed paymentMethodWhitelistId, 
        address indexed paymentMethod);

    /// @notice Emitted when a coin is removed from the approved coins mapping for a security policy
    event PaymentMethodRemovedFromWhitelist(
        uint32 indexed paymentMethodWhitelistId, 
        address indexed paymentMethod);

    /// @notice Emitted when a trusted channel is added for a collection
    event TrustedChannelAddedForCollection(
        address indexed tokenAddress, 
        address indexed channel);

    /// @notice Emitted when a trusted channel is removed for a collection
    event TrustedChannelRemovedForCollection(
        address indexed tokenAddress, 
        address indexed channel);

    /// @notice Emitted whenever pricing bounds change at a collection level for price-constrained collections.
    event UpdatedCollectionLevelPricingBoundaries(
        address indexed tokenAddress, 
        uint256 floorPrice, 
        uint256 ceilingPrice);

    /// @notice Emitted whenever the supported ERC-20 payment is set for price-constrained collections.
    event UpdatedCollectionPaymentSettings(
        address indexed tokenAddress, 
        PaymentSettings paymentSettings, 
        uint32 indexed paymentMethodWhitelistId, 
        address indexed constrainedPricingPaymentMethod,
        uint16 royaltyBackfillNumerator,
        address royaltyBackfillReceiver,
        uint16 royaltyBountyNumerator,
        address exclusiveBountyReceiver,
        bool blockTradesFromUntrustedChannels);

    /// @notice Emitted whenever pricing bounds change at a token level for price-constrained collections.
    event UpdatedTokenLevelPricingBoundaries(
        address indexed tokenAddress, 
        uint256 indexed tokenId, 
        uint256 floorPrice, 
        uint256 ceilingPrice);

    function getDomainSeparator() external view returns (bytes32);
    function masterNonces(address account) external view returns (uint256);
    function isNonceUsed(address account, uint256 nonce) external view returns (bool isUsed);
    function remainingFillableQuantity(address account, bytes32 orderDigest) external view returns (PartiallyFillableOrderStatus memory);
    function collectionPaymentSettings(address tokenAddress) external view returns (CollectionPaymentSettings memory);
    function collectionBountySettings(address tokenAddress) external view returns (uint16 royaltyBountyNumerator, address exclusiveBountyReceiver);
    function collectionRoyaltyBackfillSettings(address tokenAddress) external view returns (uint16 royaltyBackfillNumerator, address royaltyBackfillReceiver);
    function paymentMethodWhitelistOwners(uint32 paymentMethodWhitelistId) external view returns (address);
    function isPaymentMethodWhitelisted(uint32 paymentMethodWhitelistId, address paymentMethod) external view returns (bool);
    function getFloorPrice(address tokenAddress, uint256 tokenId) external view returns (uint256);
    function getCeilingPrice(address tokenAddress, uint256 tokenId) external view returns (uint256);
    function isDefaultPaymentMethod(address paymentMethod) external view returns (bool);
    function getDefaultPaymentMethods() external view returns (address[] memory);
    function createPaymentMethodWhitelist(bytes calldata data) external returns (uint32 paymentMethodWhitelistId);
    function whitelistPaymentMethod(bytes calldata data) external;
    function unwhitelistPaymentMethod(bytes calldata data) external;
    function setCollectionPaymentSettings(bytes calldata data) external;
    function setCollectionPricingBounds(bytes calldata data) external;
    function setTokenPricingBounds(bytes calldata data) external;
    function addTrustedChannelForCollection(bytes calldata data) external;
    function removeTrustedChannelForCollection(bytes calldata data) external;
    function revokeMasterNonce() external;
    function revokeSingleNonce(bytes calldata data) external;
    function revokeOrderDigest(bytes calldata data) external;
    function buyListing(bytes calldata data) external payable;
    function acceptOffer(bytes calldata data) external payable;
    function bulkBuyListings(bytes calldata data) external payable;
    function bulkAcceptOffers(bytes calldata data) external payable;
    function sweepCollection(bytes calldata data) external payable;
}
