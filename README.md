# Supply Chain Verification System

A comprehensive blockchain-based supply chain verification system built on Stacks that provides transparency, traceability, and authenticity verification for products from origin to consumer.

## 🌟 Overview

This smart contract system enables complete transparency in supply chains by tracking products through every stage of their journey. It supports multiple entity types, certification management, quality assurance checkpoints, and consumer verification - all recorded immutably on the blockchain.

## 🏗️ Architecture

### Core Components

- **Entities**: Supply chain participants (Producers, Manufacturers, Distributors, Retailers, Certification Authorities)
- **Products**: Items being tracked through the supply chain
- **Certificates**: Digital certifications for products and entities
- **Checkpoints**: Quality assurance and inspection points
- **Custody Transfers**: Ownership changes between entities
- **Consumer Verifications**: End-user authenticity checks

## 🔧 Features

### Entity Management
- **Multi-role Support**: Producers, Manufacturers, Distributors, Retailers, and Certification Authorities
- **Entity Registration**: Secure registration with authorization controls
- **Entity Verification**: Verification by contract owner or certification authorities
- **Sustainability Scoring**: Track sustainability metrics for each entity

### Product Tracking
- **Complete Lifecycle**: From origin certification to final sale
- **State Management**: Automatic state transitions based on custody transfers
- **URI Support**: Link to off-chain product data and documentation
- **Verification Status**: Track product authenticity and certification status

### Certification System
- **Multiple Certificate Types**: Organic, Fair Trade, Sustainably Sourced, Non-GMO, Carbon Neutral
- **Flexible Certification**: Certify both products and entities
- **Certificate Management**: Issue, revoke, and track certificate validity
- **Authority Control**: Only certified authorities can issue certificates

### Quality Assurance
- **Comprehensive Scoring**: Quality, sustainability, and ethical metrics (0-100 scale)
- **Checkpoint Recording**: Document inspections with evidence URIs
- **Digital Signatures**: Cryptographic verification of checkpoint authenticity
- **Location Tracking**: Geographic data for each checkpoint

### Consumer Features
- **Product Verification**: Consumers can verify product authenticity
- **Feedback System**: Rating and feedback collection (1-5 scale)
- **Journey Transparency**: View complete product history and certifications
- **Multiple Verification Methods**: Support for various verification approaches

## 📊 Data Model

### Entity Types
1. **Producer** (u1) - Origin suppliers and farmers
2. **Manufacturer** (u2) - Processing and manufacturing entities
3. **Distributor** (u3) - Distribution and logistics companies
4. **Retailer** (u4) - Final point of sale
5. **Certification Authority** (u5) - Certification and inspection bodies

### Product States
1. **Origin Certified** (u1) - Initial registration
2. **In Production** (u2) - Manufacturing phase
3. **Quality Control** (u3) - Under inspection
4. **In Transit** (u4) - Being transported
5. **At Distributor** (u5) - At distribution center
6. **At Retailer** (u6) - At retail location
7. **Sold** (u7) - Final consumer purchase

### Certification Types
1. **Organic** (u1) - Organic certification
2. **Fair Trade** (u2) - Fair trade compliance
3. **Sustainably Sourced** (u3) - Sustainable sourcing
4. **Non-GMO** (u4) - Non-genetically modified
5. **Carbon Neutral** (u5) - Carbon neutrality certification

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) - Stacks development environment
- [Node.js](https://nodejs.org/) - For running tests and scripts

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd supply-chain-verification-onStacks
```

2. Install Clarinet (if not already installed):
```bash
# macOS
brew install clarinet

# Other platforms - see Clarinet documentation
```

3. Check contract syntax:
```bash
clarinet check
```

4. Run tests:
```bash
clarinet test
```

## 📝 Usage Examples

### Register an Entity
```clarity
;; Register a new producer
(contract-call? .stacks-supply-verification register-entity 
  u"Organic Farm Inc" 
  u1  ;; Producer type
  u"California, USA" 
  u"contact@organicfarm.com"
  'SP1ABC123...)  ;; Principal address
```

### Register a Product
```clarity
;; Register a new product (must be called by verified entity)
(contract-call? .stacks-supply-verification register-product
  u"Organic Tomatoes"
  u"Fresh organic tomatoes grown without pesticides"
  u"https://ipfs.io/ipfs/QmABC123...")
```

### Issue a Certificate
```clarity
;; Issue organic certificate (must be called by certification authority)
(contract-call? .stacks-supply-verification issue-certificate
  u1  ;; Organic certification
  none  ;; No specific recipient entity
  (some u1)  ;; For product ID 1
  u1000000  ;; Valid until block 1000000
  u"https://certifications.org/organic/123")
```

### Transfer Custody
```clarity
;; Transfer product to distributor
(contract-call? .stacks-supply-verification transfer-custody
  u1  ;; Product ID
  u3  ;; To entity ID 3 (distributor)
  u"Transferred after quality inspection"
  0x1234...)  ;; Verification signature
```

### Record Quality Checkpoint
```clarity
;; Record quality inspection
(contract-call? .stacks-supply-verification record-checkpoint
  u1  ;; Product ID
  u"Quality Control"
  u"Processing Facility A"
  u95  ;; Quality score
  u88  ;; Sustainability score
  u92  ;; Ethical score
  u"All quality standards met"
  u"https://evidence.com/qc/123"
  0x5678...)  ;; Verification signature
```

## 🔍 Read-Only Functions

### Product Information
- `get-product-details(product-id)` - Get complete product information
- `get-product-certification-status(product-id)` - Get certification status
- `get-product-journey(product-id)` - Get product journey summary
- `get-product-sustainability-score(product-id)` - Get sustainability score

### Entity Information
- `get-entity-details(entity-id)` - Get entity information
- `get-entity-type(entity-id)` - Get entity type

### Certificates and Checkpoints
- `get-certificate-details(certificate-id)` - Get certificate information
- `get-checkpoint-details(checkpoint-id)` - Get checkpoint details
- `get-sustainability-summary(product-id)` - Get aggregated sustainability metrics

## 🔒 Security Features

### Authorization Controls
- **Role-based Access**: Different permissions for different entity types
- **Ownership Verification**: Only current custodians can transfer products
- **Certificate Authority**: Only certified authorities can issue certificates
- **Contract Owner**: Special privileges for contract administration

### Data Integrity
- **Cryptographic Signatures**: Digital signatures for custody transfers and checkpoints
- **Immutable Records**: All data stored permanently on blockchain
- **Validation Checks**: Comprehensive input validation and error handling
- **State Consistency**: Automatic state management prevents invalid transitions

## 🧪 Testing

The contract includes comprehensive test coverage for all functionality:

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/stacks-supply-verification_test.ts
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📋 Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u1 | ERR-NOT-AUTHORIZED | Caller not authorized for this operation |
| u2 | ERR-PRODUCT-NOT-FOUND | Product does not exist |
| u3 | ERR-INVALID-STATE-TRANSITION | Invalid product state change |
| u4 | ERR-CHECKPOINT-NOT-FOUND | Checkpoint does not exist |
| u5 | ERR-ENTITY-NOT-FOUND | Entity does not exist |
| u6 | ERR-CERTIFICATE-NOT-FOUND | Certificate does not exist |
| u7 | ERR-ALREADY-EXISTS | Entity or resource already exists |
| u8 | ERR-NOT-CURRENT-CUSTODIAN | Not the current product custodian |
| u9 | ERR-INVALID-CERTIFICATION | Invalid or expired certification |
| u10 | ERR-INVALID-RATING | Rating outside valid range |

## 🔮 Future Enhancements

- **Multi-signature Transfers**: Require multiple signatures for high-value transfers
- **IoT Integration**: Automated checkpoint recording from IoT sensors
- **Carbon Footprint Tracking**: Detailed emissions tracking throughout supply chain
- **Supply Chain Analytics**: Advanced reporting and analytics dashboard
- **Mobile App Integration**: Consumer-facing mobile application
- **API Gateway**: RESTful API for external system integration

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on [Stacks](https://stacks.co) blockchain platform
- Developed with [Clarinet](https://github.com/hirosystems/clarinet) development environment
- Inspired by the need for transparent and ethical supply chains

## 📞 Support

For support, questions, or contributions:
- Create an issue in this repository
- Contact the development team
- Join our community discussions

---

*Building trust through transparency in global supply chains* 🌍✨
