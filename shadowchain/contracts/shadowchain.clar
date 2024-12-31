;; Crypto Collectible Battler NFT Smart Contract

;; Constants for contract errors
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-NFT (err u101))
(define-constant ERR-LOW-BALANCE (err u102))
(define-constant ERR-COMBAT-PROHIBITED (err u103))

;; Character traits structure
(define-map nft_data 
  {token_id: uint} 
  {
    title: (string-ascii 50),
    offense: uint,
    resilience: uint,
    vitality: uint,
    rank: uint,
    tier: (string-ascii 20)
  }
)

;; Track character ownership
(define-map nft_ownership 
  {token_id: uint} 
  {holder: principal}
)

;; Battle history tracking
(define-map combat_log 
  {combat_id: uint} 
  {
    aggressor_id: uint, 
    target_id: uint, 
    victor_id: uint,
    block_time: uint
  }
)

;; Minting fee and next character ID
(define-data-var creation_cost uint u10000000) ;; 0.1 STX
(define-data-var token_id_counter uint u1)
(define-data-var nft_supply uint u0)

;; Character Creation Function
(define-public (mint_nft 
  (title (string-ascii 50)) 
  (tier (string-ascii 20))
)
  (let (
    (token_id (var-get token_id_counter))
    (base_offense (if (is-eq tier "legendary") u50 
                  (if (is-eq tier "rare") u30 
                    (if (is-eq tier "common") u10 u20))))
    (base_resilience (if (is-eq tier "legendary") u50 
                   (if (is-eq tier "rare") u30 
                     (if (is-eq tier "common") u10 u20))))
  )
    ;; Require minting fee
    (try! (stx-transfer? (var-get creation_cost) tx-sender (as-contract tx-sender)))

    ;; Create character in map
    (map-set nft_data 
      {token_id: token_id} 
      {
        title: title, 
        offense: base_offense,
        resilience: base_resilience,
        vitality: u100, 
        rank: u1,
        tier: tier
      }
    )

    ;; Set character owner
    (map-set nft_ownership 
      {token_id: token_id} 
      {holder: tx-sender}
    )

    ;; Increment tracking variables
    (var-set token_id_counter (+ token_id u1))
    (var-set nft_supply (+ (var-get nft_supply) u1))

    (ok token_id)
))

;; Battle Function
(define-public (initiate_combat 
  (aggressor_id uint) 
  (target_id uint)
)
  (let (
    (aggressor_holder (unwrap! 
      (get-nft-holder aggressor_id) 
      (err ERR-INVALID-NFT)
    ))
    (target_holder (unwrap! 
      (get-nft-holder target_id) 
      (err ERR-INVALID-NFT)
    ))
    (aggressor_stats (unwrap! 
      (get-nft-stats aggressor_id) 
      (err ERR-INVALID-NFT)
    ))
    (target_stats (unwrap! 
      (get-nft-stats target_id) 
      (err ERR-INVALID-NFT)
    ))
    (offense_power (get offense aggressor_stats))
    (defense_power (get resilience target_stats))
    (victor_id (if (> offense_power defense_power) 
                  aggressor_id 
                  target_id))
  )
    ;; Prevent battling own characters
    (asserts! (not (is-eq aggressor_holder target_holder)) 
      (err ERR-COMBAT-PROHIBITED))

    ;; Record battle in history
    (map-set combat_log 
      {combat_id: (var-get token_id_counter)} 
      {
        aggressor_id: aggressor_id, 
        target_id: target_id, 
        victor_id: victor_id,
        block_time: block-height
      }
    )

    (ok victor_id)
))

;; Character Level Up Function
(define-public (upgrade_nft (token_id uint))
  (let (
    (nft (unwrap! 
      (get-nft-stats token_id) 
      (err ERR-INVALID-NFT)
    ))
    (holder (unwrap! 
      (get-nft-holder token_id) 
      (err ERR-INVALID-NFT)
    ))
  )
    ;; Only owner can level up
    (asserts! (is-eq tx-sender holder) (err ERR-UNAUTHORIZED))

    ;; Increase character stats
    (map-set nft_data 
      {token_id: token_id} 
      (merge nft {
        offense: (+ (get offense nft) u5),
        resilience: (+ (get resilience nft) u5),
        vitality: (+ (get vitality nft) u10),
        rank: (+ (get rank nft) u1)
      })
    )

    (ok true)
))

;; Read-only Functions for Character Details
(define-read-only (get-nft-stats (token_id uint))
  (map-get? nft_data {token_id: token_id})
)

(define-read-only (get-nft-holder (token_id uint))
  (get holder (map-get? nft_ownership {token_id: token_id}))
)

;; Initialize the contract
(begin 
  (var-set creation_cost u10000000)  ;; 0.1 STX initial mint fee
  (var-set token_id_counter u1)
  (var-set nft_supply u0)
)