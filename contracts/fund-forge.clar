;; FundForge: Revolutionary Blockchain-Based Crowdfunding Platform
;;
;; Empowering Innovation Through Decentralized Funding
;;
;; FundForge revolutionizes project funding by creating a transparent, secure, and 
;; community-driven ecosystem where creators and backers connect directly on the 
;; blockchain. Built on Stacks and backed by Bitcoin's security, this protocol 
;; eliminates traditional intermediaries while providing unprecedented transparency
;; and accountability through smart contract automation.
;;
;; Core Capabilities:
;; - Zero-trust funding mechanism with automatic escrow
;; - Community-driven project validation through weighted voting
;; - Instant, guaranteed refunds for failed campaigns
;; - Creator incentive alignment with milestone-based releases
;; - Transparent fee structure with minimal platform costs
;; - Flexible campaign customization for diverse project types
;;
;; Contract Architecture: Advanced state management with robust error handling,
;; comprehensive input validation, and gas-optimized operations for scalable
;; crowdfunding at enterprise scale.
;;

;; SYSTEM CONSTANTS & CONFIGURATION

;; Contract Governance
(define-constant CONTRACT_OWNER tx-sender)

;; Error Code Registry
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u101))
(define-constant ERR_CAMPAIGN_ENDED (err u102))
(define-constant ERR_CAMPAIGN_ACTIVE (err u103))
(define-constant ERR_GOAL_NOT_MET (err u104))
(define-constant ERR_ALREADY_REFUNDED (err u105))
(define-constant ERR_NO_CONTRIBUTION (err u106))
(define-constant ERR_INVALID_AMOUNT (err u107))
(define-constant ERR_INVALID_PARAMETERS (err u108))
(define-constant ERR_VOTING_PERIOD_ENDED (err u109))
(define-constant ERR_ALREADY_VOTED (err u110))
(define-constant ERR_INSUFFICIENT_VOTING_POWER (err u111))
(define-constant ERR_CONTRIBUTOR_LIST_FULL (err u112))
(define-constant ERR_INVALID_STRING (err u113))

;; Campaign State Definitions
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_SUCCESSFUL u2)
(define-constant STATUS_FAILED u3)
(define-constant STATUS_CANCELLED u4)

;; Protocol Limits & Constraints
(define-constant MAX_DURATION_BLOCKS u144000) ;; ~100 days at 10 min blocks
(define-constant MAX_VOTING_DURATION_BLOCKS u14400) ;; ~10 days
(define-constant MIN_DURATION_BLOCKS u144) ;; ~1 day
(define-constant MAX_CAMPAIGN_ID u1000000) ;; Reasonable upper bound

;; GLOBAL STATE VARIABLES

(define-data-var campaign-counter uint u0)
(define-data-var platform-fee-rate uint u250) ;; 2.5% (250/10000)

;; CORE DATA STRUCTURES

;; Primary Campaign Registry
(define-map campaigns
  { campaign-id: uint }
  {
    creator: principal,
    title: (string-ascii 64),
    description: (string-ascii 256),
    goal: uint,
    raised: uint,
    deadline-height: uint,
    created-height: uint,
    status: uint,
    voting-enabled: bool,
    voting-deadline-height: uint,
    votes-for: uint,
    votes-against: uint,
    min-contribution: uint,
  }
)

;; Contributor Investment Tracking
(define-map contributions
  {
    campaign-id: uint,
    contributor: principal,
  }
  {
    amount: uint,
    refunded: bool,
    voting-power: uint,
  }
)

;; Governance Vote Registry
(define-map contributor-votes
  {
    campaign-id: uint,
    voter: principal,
  }
  {
    voted: bool,
    vote-for: bool,
  }
)

;; Campaign Stakeholder Directory
(define-map campaign-contributors
  { campaign-id: uint }
  { contributor-list: (list 500 principal) }
)

;; READ-ONLY QUERY FUNCTIONS

;; Retrieve comprehensive campaign information
(define-read-only (get-campaign (campaign-id uint))
  (map-get? campaigns { campaign-id: campaign-id })
)

;; Query specific contributor investment details
(define-read-only (get-contribution
    (campaign-id uint)
    (contributor principal)
  )
  (map-get? contributions {
    campaign-id: campaign-id,
    contributor: contributor,
  })
)

;; Get total platform campaign count
(define-read-only (get-campaign-count)
  (var-get campaign-counter)
)

;; Get current platform fee structure
(define-read-only (get-platform-fee-rate)
  (var-get platform-fee-rate)
)

;; Validate campaign active status
(define-read-only (is-campaign-active (campaign-id uint))
  (match (get-campaign campaign-id)
    campaign (and
      (is-eq (get status campaign) STATUS_ACTIVE)
      (< stacks-block-height (get deadline-height campaign))
    )
    false
  )
)

;; Verify campaign funding goal achievement
(define-read-only (is-campaign-successful (campaign-id uint))
  (match (get-campaign campaign-id)
    campaign (>= (get raised campaign) (get goal campaign))
    false
  )
)

;; Calculate platform fee for given amount
(define-read-only (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u10000)
)