# LifeWatch ERIC Metadata Catalogue

🌐 https://metadatacatalogue.lifewatch.eu/

## Overview

The **LifeWatch ERIC Metadata Catalogue** is a centralised platform for discovering, managing, and sharing biodiversity and ecosystem metadata. It is operational since 2020, built on **GeoNetwork 4.2.11** and extended with custom configurations to support domain-specific requirements, including:

- Custom **EML (Ecological Metadata Language) transformations**
- Advanced **metadata harvesting workflows**
- **FAIRness checker** thanks to the F-UJI integration
- Tailored user interface and catalogue behavior

This catalogue supports interoperability, standardisation, and accessibility of environmental metadata across LifeWatch ERIC Distributed Centres and other European partner infrastructures.

---

## Features

- 🔎 **Metadata Discovery**  
  Powerful search and filtering capabilities for environmental datasets.

- 🔄 **Harvesting Mechanisms**  
  Automated ingestion of metadata from external sources.

- 🧬 **Custom EML Transformation**  
  Extended support for EML schemas through custom XSL transformations.

- 🌍 **Standards Compliance**  
  Supports ISO19115/19139, Dublin Core, and EML.

- 👥 **User & Role Management**  
  Fine-grained access control and publishing workflows.

- 🧩 **GeoNetwork-based Architecture**  
  Built on GeoNetwork **v4.2.11** with custom extensions.

---

## Technology Stack

- **GeoNetwork**: 4.2.11
- **Java**: 11+
- **Database**: PostgreSQL (recommended)
- **Search Engine**: Elasticsearch (bundled with GeoNetwork)
- **Metadata Standards**:
    - ISO19139
    - Dublin Core
    - EML (customised)

---

## Customisations

### 1. EML Transformation

This project includes custom transformations for handling **Ecological Metadata Language (EML)** records:

- Custom XSLT stylesheets for:
    - Importing EML into GeoNetwork
    - Rendering EML in the UI
    - Exporting EML-compliant metadata
- Mapping between EML and GeoNetwork internal schema


---

### 2. Harvesting Configuration

Enhanced harvesting capabilities include:

- Scheduled harvesting from remote catalogues (CSW, OAI-PMH, etc.)
- Custom pipelines for transforming incoming metadata
- Support for EML sources

Configuration typically involves:
- Harvesting settings in GeoNetwork admin UI
- Custom transformation hooks during ingestion

---

### 3. UI & Configuration Extensions

- Customised portal interface
- Tailored search filters and facets
- Branding aligned with LifeWatch ERIC services

---



## Usage

### Publishing Metadata

- Log in as an editor
- Create metadata records
- Publish records for discovery

### Harvesting

- Configure harvesters via Admin → Harvesting
- Select source type (CSW, OAI-PMH, etc.)
- Define transformation rules if needed

---

## Project Structure (Simplified)

```
├── schemas/
│   ├── iso19115/
│   ├── dublin-core/
│   ├── schema-core/
│   ├── eml-gbif/
│   └── pom.xml/
│ 
├── web/
├── web-ui/
└── README.md
```

---


## License

GPL-2.0 License

---

## Acknowledgements

- GeoNetwork OpenSource community
- LifeWatch ERIC Research Infrastructure
- Contributors and domain experts in biodiversity informatics

---

## Contact

For support or questions:

- 🌐 https://metadatacatalogue.lifewatch.eu/
- 📧 service.centre@lifewatch.eu
- 🌐 https://helpdesk.lifewatch.eu/
