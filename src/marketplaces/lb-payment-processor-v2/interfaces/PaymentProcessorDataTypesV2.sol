// SPDX-License-Identifier: MIT
pragma solidity >=0.8.7;

enum Sides { 
    Buy, 
    Sell 
}

enum OrderProtocols { 
    ERC721_FILL_OR_KILL, 
    ERC1155_FILL_OR_KILL,
    ERC1155_FILL_PARTIAL
}

enum PaymentSettings { 
    DefaultPaymentMethodWhitelist,
    AllowAnyPaymentMethod,
    CustomPaymentMethodWhitelist,
    PricingConstraints
}

struct DefaultPaymentMethods {
    address defaultPaymentMethod1;
    address defaultPaymentMethod2;
    address defaultPaymentMethod3;
    address defaultPaymentMethod4;
}

struct CollectionPaymentSettings {
    PaymentSettings paymentSettings;
    uint32 paymentMethodWhitelistId;
    address constrainedPricingPaymentMethod;
    uint16 royaltyBackfillNumerator;
    uint16 royaltyBountyNumerator;
    bool isRoyaltyBountyExclusive;
    bool blockTradesFromUntrustedChannels;
}

/**
 * @dev The `v`, `r`, and `s` components of an ECDSA signature.  For more information
 *      [refer to this article](https://medium.com/mycrypto/the-magic-of-digital-signatures-on-ethereum-98fe184dc9c7).
 */
struct SignatureECDSA {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct Order {
    OrderProtocols protocol;
    address maker;
    address beneficiary;
    address marketplace;
    address fallbackRoyaltyRecipient;
    address paymentMethod;
    address tokenAddress;
    uint256 tokenId;
    uint248 amount;
    uint256 itemPrice;
    uint256 nonce;
    uint256 expiration;
    uint256 marketplaceFeeNumerator;
    uint256 maxRoyaltyFeeNumerator;
    uint248 requestedFillAmount;
    uint248 minimumFillAmount;
}

struct Cosignature {
    address signer;
    address taker;
    uint256 expiration;
    uint8 v;
    bytes32 r;
    bytes32 s;
}

struct FeeOnTop {
    address recipient;
    uint256 amount;
}

struct TokenSetProof {
    bytes32 rootHash;
    bytes32[] proof;
}

enum PartiallyFillableOrderState { 
    Open, 
    Filled, 
    Cancelled
}

struct PartiallyFillableOrderStatus {
    PartiallyFillableOrderState state;
    uint248 remainingFillableQuantity;
}

struct RoyaltyBackfillAndBounty {
    uint16 backfillNumerator;
    address backfillReceiver;
    uint16 bountyNumerator;
    address exclusiveMarketplace;
}

struct SweepOrder {
    OrderProtocols protocol;
    address tokenAddress;
    address paymentMethod;
    address beneficiary;
}

struct SweepItem {
    address maker;
    address marketplace;
    address fallbackRoyaltyRecipient;
    uint256 tokenId;
    uint248 amount;
    uint256 itemPrice;
    uint256 nonce;
    uint256 expiration;
    uint256 marketplaceFeeNumerator;
    uint256 maxRoyaltyFeeNumerator;
}

/**
 * @dev This struct is used to define pricing constraints for a collection or individual token.
 *
 * @dev **isSet**: When true, this indicates that pricing constraints are set for the collection or token.
 * @dev **floorPrice**: The minimum price for a token or collection.  This is only enforced when 
 * @dev `enforcePricingConstraints` is `true`.
 * @dev **ceilingPrice**: The maximum price for a token or collection.  This is only enforced when
 * @dev `enforcePricingConstraints` is `true`.
 */
struct PricingBounds {
    bool isSet;
    uint120 floorPrice;
    uint120 ceilingPrice;
}

struct BulkAcceptOffersParams {
    bool[] isCollectionLevelOfferArray;
    Order[] saleDetailsArray;
    SignatureECDSA[] buyerSignaturesArray;
    TokenSetProof[] tokenSetProofsArray;
    Cosignature[] cosignaturesArray;
    FeeOnTop[] feesOnTopArray;
}