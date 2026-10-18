# Serial Link PHY (PCIe / USB 3.0 PIPE Compliant)

This repository contains the design, implementation, and verification of a **Serial Link Physical Layer (PHY)** compliant with the **Intel PIPE 3.0 (PHY Interface for PCI Express and USB 3.0)** specification.

---

## 1. Project Architecture Overview

The Serial Link PHY is structured into three primary sub-blocks:

```
                          +-----------------------------------+
                          |            MAC Layer              |
                          +-----------------------------------+
                                    |               ^
                         PIPE TxBus |               | PIPE RxBus
                                    v               |
           +-----------------------------------------------------------------+
           |                       Serial Link PHY                           |
           |                                                                 |
           |   +-------------------+                   +-----------------+   |
           |   |  Transmitter (TX) |                   |  Receiver (RX)  |   |
           |   |   - 8b/10b Enc    |                   |   - Clock & Data|   |
           |   |   - Compliance    |=== Loopback (10b)=|     Recovery    |   |
           |   |   - Serializer    |                   |   - Elastic Buf |   |
           |   |   - Diff Driver   |                   |   - 8b/10b Dec  |   |
           |   +-------------------+                   +-----------------+   |
           |             |                                      ^            |
           |             | TX+/TX-                              | RX+/RX-    |
           |             v                                      |            |
           +-----------------------------------------------------------------+
```

- **`RTL/TX/`**: Transmitter chain (Width conversion, 8b/10b encoder, compliance generators, loopback path, serializer, and differential driver).
- **`RTL/RX/`**: Receiver chain (Differential receiver, clock & data recovery DRC, deserializer, comma detect/aligner, elastic buffer, and 8b/10b decoder).
- **`RTL/CMN/`**: Common clocking, PLL, reset controllers, and power management logic.

---

## 2. Transmitter (TX) Architecture & 8b/10b Encoder

The transmitter block encodes parallel data symbols into DC-balanced 10-bit symbols with bounded run-length, supporting both PCI Express and USB 3.0 SuperSpeed modes.

```
                   TxData [7:0]    TxDataK
                        \             /
                         v           v
                     +--------------------+
TxCompliance ------->|   8b/10b Encoder   |
                     |       Engine       |<-- clk (Bit rate clk / 10)
                     |    (5b/6b + 3b/4b  |<-- rst_n
                     |     + Disparity)   |
                     +--------------------+
                               |
                               | enc_data_10b [9:0]
                               v
                     +--------------------+
TxOnesZeroes ------->| USB CP7/8 Override | (Alternating 1s / 0s for USB 3.0)
                     +--------------------+
                               |
RxLoopbackData ----->|   Loopback Mux     |<-- loopback_en
   [9:0]             +--------------------+
                               |
                               v
                        TxData10b [9:0] (To Serializer)
```

### Signal Interface Definition

| Port Name | Direction | Width | Clock Domain | Description |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | Input | 1 | — | Symbol clock (`Bit rate clk / 10` = 250 MHz for PCIe Gen1 / USB3) |
| `rst_n` | Input | 1 | Async | Active-low asynchronous reset |
| `tx_data` | Input | [7:0] | `clk` | 8-bit input symbol byte ($HGF\ EDCBA$) |
| `tx_datak` | Input | 1 | `clk` | Special character indicator ($0 = D.x.y$, $1 = K.x.y$) |
| `tx_compliance` | Input | 1 | `clk` | PCIe mode: forces running disparity to negative ($RD^-$) |
| `tx_oneszeros` | Input | 1 | `clk` | USB 3.0 mode: CP7/CP8 compliance override (50-250 1s / 0s) |
| `rx_loopback_data` | Input | [9:0] | `clk` | 10-bit recovered parallel symbol from receiver loopback |
| `loopback_en` | Input | 1 | `clk` | Internal loopback enable (`TxDetectRx/Loopback` & `!TxElecIdle`) |
| `tx_data_10b` | Output | [9:0] | `clk` | 10-bit DC-balanced symbol output ($a b c d e i\ f g h j$) |
| `current_rd` | Output | 1 | `clk` | Running disparity state ($0 = RD^-$, $1 = RD^+$) |
| `illegal_k_err` | Output | 1 | `clk` | Flags an invalid / unsupported $K$-code input |

---

## 3. Directory Layout

```
Serial-Link-PHY-GP/
├── README.md               # Project documentation and specifications
└── RTL/
    ├── CMN/                # Common infrastructure & PLL logic
    ├── RX/                 # Receiver pipeline
    └── TX/                 # Transmitter pipeline
        ├── encoder_8b10b.sv    # Core 8b/10b encoder with RD tracking
        └── tx_encoder_top.sv   # TX encoder top with compliance & loopback
```

---

## 4. References
- Intel PHY Interface for the PCI Express and USB 3.0 Architectures (PIPE Specification v3.0)
- PCI Express Base Specification, Revision 2.0 / 3.0
- Universal Serial Bus 3.0 Specification, Chapter 6 (Physical Layer)
- Widmer, A. X., & Franaszek, P. A. (1983). *A DC-Balanced, Partitioned-Block, 8B/10B Transmission Code*. IBM Journal of Research and Development.