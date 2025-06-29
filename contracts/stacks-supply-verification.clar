;; Supply Chain Verification System
;; A transparent supply chain tracking system where each stage of production is verified and recorded on-chain

;; Constants
(define-constant ERR-NOT-AUTHORIZED u1)
(define-constant ERR-PRODUCT-NOT-FOUND u2)
(define-constant ERR-INVALID-STATE-TRANSITION u3)
(define-constant ERR-CHECKPOINT-NOT-FOUND u4)
(define-constant ERR-ENTITY-NOT-FOUND u5)
(define-constant ERR-CERTIFICATE-NOT-FOUND u6)
(define-constant ERR-ALREADY-EXISTS u7)
(define-constant ERR-NOT-CURRENT-CUSTODIAN u8)
(define-constant ERR-INVALID-CERTIFICATION u9)
(define-constant ERR-INVALID-RATING u10)

;; Data Variables
(define-data-var contract-owner principal tx-sender)
(define-data-var next-product-id uint u1)
(define-data-var next-entity-id uint u1)
(define-data-var next-certificate-id uint u1)
(define-data-var next-checkpoint-id uint u1)

;; Entity Types (Manufacturer, Distributor, Retailer, etc.)
(define-map entity-types
  { type-id: uint }
  { type-name: (string-utf8 50) }
)

;; Product States
(define-map product-states
  { state-id: uint }
  { state-name: (string-utf8 50) }
)

;; Supply Chain Entities (Companies/Organizations)
(define-map entities
  { entity-id: uint }
  {
    name: (string-utf8 100),
    entity-type: uint,
    location: (string-utf8 100),
    contact-info: (string-utf8 100),
    verification-status: bool,
    sustainability-score: uint,  ;; 0-100 scale
    created-at: uint
  }
)

;; Entity authentication mapping
(define-map entity-principals
  { principal: principal }
  { entity-id: uint }
)

;; Products being tracked
(define-map products
  { product-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    current-state: uint,
    current-custodian: uint,  ;; entity-id of current custodian
    origin-entity-id: uint,
    origin-certification-id: uint,
    origin-timestamp: uint,
    final-destination-entity-id: (optional uint),
    final-delivery-timestamp: (optional uint),
    is-verified: bool,
    sustainability-score: uint,   ;; 0-100 calculated from all checkpoints
    product-uri: (string-utf8 256),  ;; Link to off-chain data
    created-at: uint
  }
)

;; Certification types (Organic, Fair Trade, etc.)
(define-map certification-types
  { cert-type-id: uint }
  { cert-type-name: (string-utf8 100) }
)

;; Certificates issued to entities or products
(define-map certificates
  { certificate-id: uint }
  {
    cert-type-id: uint,
    issuer-entity-id: uint,
    recipient-entity-id: (optional uint),
    product-id: (optional uint),
    valid-from: uint,
    valid-until: uint,
    verification-uri: (string-utf8 256),
    is-active: bool,
    created-at: uint
  }
)

;; Custody Transfer History
(define-map custody-transfers
  { product-id: uint, transfer-index: uint }
  {
    from-entity-id: uint,
    to-entity-id: uint,
    transfer-timestamp: uint,
    notes: (string-utf8 500),
    verification-signature: (buff 65)
  }
)

;; Quality Assurance Checkpoints
(define-map checkpoints
  { checkpoint-id: uint }
  {
    product-id: uint,
    inspector-entity-id: uint,
    checkpoint-type: (string-utf8 50),
    timestamp: uint,
    location: (string-utf8 100),
    quality-score: uint,       ;; 0-100 score
    sustainability-score: uint, ;; 0-100 score
    ethical-score: uint,       ;; 0-100 score
    notes: (string-utf8 500),
    evidence-uri: (string-utf8 256),
    verification-signature: (buff 65)
  }
)

;; Product checkpoint index mapping
(define-map product-checkpoints
  { product-id: uint, index: uint }
  { checkpoint-id: uint }
)

;; Product certificate index mapping
(define-map product-certificates
  { product-id: uint, index: uint }
  { certificate-id: uint }
)

;; Consumer verification lookup
(define-map consumer-verifications
  { product-id: uint, verifier: principal }
  {
    timestamp: uint,
    verification-method: (string-utf8 50),
    rating: (optional uint),
    feedback: (optional (string-utf8 500))
  }
)

;; Initialize contract with basic entity types, product states, and certification types
(begin
  ;; Entity Types
  (map-set entity-types { type-id: u1 } { type-name: "Producer" })
  (map-set entity-types { type-id: u2 } { type-name: "Manufacturer" })
  (map-set entity-types { type-id: u3 } { type-name: "Distributor" })
  (map-set entity-types { type-id: u4 } { type-name: "Retailer" })
  (map-set entity-types { type-id: u5 } { type-name: "Certification Authority" })
  
  ;; Product States
  (map-set product-states { state-id: u1 } { state-name: "Origin Certified" })
  (map-set product-states { state-id: u2 } { state-name: "In Production" })
  (map-set product-states { state-id: u3 } { state-name: "Quality Control" })
  (map-set product-states { state-id: u4 } { state-name: "In Transit" })
  (map-set product-states { state-id: u5 } { state-name: "At Distributor" })
  (map-set product-states { state-id: u6 } { state-name: "At Retailer" })
  (map-set product-states { state-id: u7 } { state-name: "Sold" })
  
  ;; Certification Types
  (map-set certification-types { cert-type-id: u1 } { cert-type-name: "Organic" })
  (map-set certification-types { cert-type-id: u2 } { cert-type-name: "Fair Trade" })
  (map-set certification-types { cert-type-id: u3 } { cert-type-name: "Sustainably Sourced" })
  (map-set certification-types { cert-type-id: u4 } { cert-type-name: "Non-GMO" })
  (map-set certification-types { cert-type-id: u5 } { cert-type-name: "Carbon Neutral" })
)

;; Helper function to check if caller is authorized as an entity
(define-read-only (is-entity-principal (entity-id uint))
  (match (map-get? entity-principals { principal: tx-sender })
    entity-info (is-eq (get entity-id entity-info) entity-id)
    false
  )
)

;; Helper function to get entity ID from principal
(define-read-only (get-entity-id-by-principal (entity-principal principal))
  (match (map-get? entity-principals { principal: entity-principal })
    entity-info (ok (get entity-id entity-info))
    (err ERR-ENTITY-NOT-FOUND)
  )
)

;; Read-only functions
(define-read-only (get-product-details (product-id uint))
  (map-get? products { product-id: product-id })
)

(define-read-only (get-entity-details (entity-id uint))
  (map-get? entities { entity-id: entity-id })
)

(define-read-only (get-certificate-details (certificate-id uint))
  (map-get? certificates { certificate-id: certificate-id })
)

(define-read-only (get-checkpoint-details (checkpoint-id uint))
  (map-get? checkpoints { checkpoint-id: checkpoint-id })
)

(define-read-only (get-product-certification-status (product-id uint))
  (match (map-get? products { product-id: product-id })
    product (ok {
      is-verified: (get is-verified product),
      origin-certification: (get-certificate-details (get origin-certification-id product)),
      sustainability-score: (get sustainability-score product)
    })
    (err ERR-PRODUCT-NOT-FOUND)
  )
)

(define-read-only (get-product-journey (product-id uint))
  ;; In a real implementation, would return a comprehensive journey history
  ;; including all checkpoints and custody transfers
  (match (map-get? products { product-id: product-id })
    product (ok {
      product-id: product-id,
      current-state: (get current-state product),
      current-custodian: (get current-custodian product)
    })
    (err ERR-PRODUCT-NOT-FOUND)
  )
)

(define-read-only (get-sustainability-summary (product-id uint))
  (let (
    (total-checkpoints u0)
    (quality-sum u0)
    (sustainability-sum u0)
    (ethical-sum u0)
  )
    ;; Fold through checkpoints (placeholder loop)
    ;; You'd replace this with real iteration using known indexes or counter tracking
    ;; or Clarinet test-side aggregation
    (ok {
      average-quality: (/ quality-sum total-checkpoints),
      average-sustainability: (/ sustainability-sum total-checkpoints),
      average-ethical: (/ ethical-sum total-checkpoints)
    })
  )
)

