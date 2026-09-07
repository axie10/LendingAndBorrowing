# 🏦 Lending & Borrowing Protocol

> Protocolo de préstamos descentralizados construido paso a paso como parte del Máster de Blockchain Development.
> El objetivo no es solo terminar el curso, sino entender **cómo piensan los ingenieros de DeFi** al diseñar mercados de dinero on-chain.

---

## 🎯 Objetivo del proyecto

Diseñar e implementar desde cero un protocolo de **lending & borrowing** al estilo Aave / Compound, cubriendo:

- Depósitos y retiros de liquidez por parte de *lenders*.
- Solicitud, repago y liquidación de préstamos por parte de *borrowers*.
- Gestión multi-mercado con parámetros de riesgo por activo.
- Control de solvencia mediante *collateralization ratio* y *liquidation threshold*.
- Firmas *off-chain* para mejorar UX y ahorrar gas.
- Cobertura completa con tests unitarios y de integración.

---

## 🧠 Conceptos clave que se trabajan

| Área | Conceptos |
|------|-----------|
| **DeFi Fundamentals** | Overcollateralization, utilization rate, interest rate models |
| **Solidity** | Modifiers, access control, upgradeability, pausable patterns |
| **Seguridad** | Reentrancy, oracle safety, CEI pattern, pull-over-push |
| **Arquitectura** | Multi-market design, storage layout, separación de responsabilidades |
| **Gas** | Storage packing, `unchecked`, custom errors |
| **UX** | EIP-712 / off-chain signatures (permit style) |
| **Testing** | Foundry (fuzzing, invariants, forked mainnet) |

---

## 🗺️ Roadmap del proyecto

Progreso a través de los capítulos del máster:

- [x] **01 · Préstamos descentralizados** — Introducción teórica al concepto de lending en DeFi.
- [ ] **02 · Sistema de préstamos** — Estructura base del contrato: depósitos, préstamos y estado del pool.
- [ ] **03 · Crear un sistema multimercado** — Refactor para soportar múltiples activos (ERC-20) en un mismo protocolo.
- [ ] **04 · Liquidation threshold** — Definición de umbrales de liquidación por mercado.
- [ ] **05 · Crear nuevos mercados** — Función administrativa para dar de alta mercados.
- [ ] **06 · Actualizar mercados existentes** — Modificar parámetros de riesgo de mercados ya creados.
- [ ] **07 · Crear protocolos pausables** — Circuit breaker para emergencias (`Pausable` de OpenZeppelin).
- [ ] **08 · Depósito de préstamos (lender)** — Función `deposit()` con emisión de aTokens/shares.
- [ ] **09 · Retiro de préstamos (lender)** — Función `withdraw()` con validaciones de liquidez.
- [ ] **10 · Borrower** — Solicitar préstamos contra colateral.
- [ ] **11 · Cálculo de ratios** — Health factor, utilization, LTV.
- [ ] **12 · Control de préstamos on-chain** — Tracking del estado de cada posición.
- [ ] **13 · Collateralization Ratio** — Validación de solvencia en cada operación.
- [ ] **14 · Liquidación de posiciones** — Función `liquidate()` con incentivo al liquidador.
- [ ] **15 · Off-chain signatures** — Meta-transacciones y firmas EIP-712.
- [ ] **16 · Testing** — Cobertura completa: unit tests, fuzzing e invariantes.

---

## 🏗️ Arquitectura (borrador inicial)

```
┌─────────────────────────────────────────────────────────┐
│                    LendingProtocol                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │   Markets    │  │  Positions   │  │  Liquidator  │  │
│  │  (per asset) │  │  (per user)  │  │              │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                 │                  │           │
│         ▼                 ▼                  ▼           │
│  ┌──────────────────────────────────────────────────┐  │
│  │              InterestRateModel                    │  │
│  │        (utilization → borrow/supply rates)        │  │
│  └──────────────────────────────────────────────────┘  │
│                          │                               │
│                          ▼                               │
│  ┌──────────────────────────────────────────────────┐  │
│  │                 PriceOracle                       │  │
│  │              (Chainlink feeds)                    │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Stack técnico

- **Solidity** `^0.8.24`
- **Foundry** (forge, cast, anvil) — testing y deployment
- **OpenZeppelin Contracts** — `Ownable`, `Pausable`, `ERC20`, `ReentrancyGuard`
- **Chainlink** — Price feeds (a partir del capítulo de colateralización)

---

## 🚀 Setup

### Requisitos previos

- [Foundry](https://book.getfoundry.sh/getting-started/installation) instalado
- Node.js 20+ (opcional, solo si añades scripts auxiliares)

### Instalación

```bash
# Clonar el repo
git clone https://github.com/axie10/lending-and-borrowing.git
cd lending-and-borrowing

# Instalar dependencias
forge install OpenZeppelin/openzeppelin-contracts
forge install smartcontractkit/chainlink-brownie-contracts

# Compilar
forge build

# Tests
forge test -vvv
```

### `remappings.txt`

```
@openzeppelin/=lib/openzeppelin-contracts/
@chainlink/=lib/chainlink-brownie-contracts/
```

---

## 📂 Estructura de carpetas

```
lending-and-borrowing/
├── src/
│   ├── LendingProtocol.sol
│   ├── interfaces/
│   ├── libraries/
│   └── mocks/
├── test/
│   ├── unit/
│   ├── integration/
│   └── invariant/
├── script/
│   └── Deploy.s.sol
├── foundry.toml
└── remappings.txt
```

---

## 📝 Bitácora de aprendizaje

Cada capítulo se cierra con una nota breve en `/notes/` respondiendo a:

1. **¿Qué he construido?**
2. **¿Qué decisión de diseño ha sido la más interesante?**
3. **¿Qué vulnerabilidad podría haber si esto se desplegase en mainnet?**
4. **¿Cómo lo resuelven Aave / Compound en producción?**

---

## 🔗 Referencias

- [Aave V3 · Whitepaper](https://github.com/aave/aave-v3-core)
- [Compound V2 · Documentation](https://docs.compound.finance/v2/)
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/5.x/)

---

## 👤 Autor

**Axie** — [github.com/axie10](https://github.com/axie10)
Frontend Developer en transición a Blockchain Engineer.

---