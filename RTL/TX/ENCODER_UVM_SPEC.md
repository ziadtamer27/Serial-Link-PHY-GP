# 8b/10b Encoder UVM Verification Specification & Architecture Document

**Document Version:** 2.0  
**Target DUT:** `encoder_8b10b_top.sv`  
**Applicable Standards:** USB 3.0 SuperSpeed (Chapter 6), PCI Express Base Spec Rev 2.0/3.0, Intel PIPE 3.0  
**Encoding Reference:** Widmer & Franaszek IBM 8B/10B Transmission Code (IEEE 802.3 Clause 36.2.4)  
**Verification Framework:** Universal Verification Methodology (UVM 1.2)  
**File Naming Requirement:** All UVM classes **must** use the `.svh` file extension; packages, modules, and interfaces use `.sv`.

---

## 1. Executive Summary & Verification Scope

This document provides a comprehensive verification plan and architectural specification for the Transmit (TX) **8b/10b Encoder** subsystem of the **Serial Link PHY**, which is designed to be compliant with both **USB 3.0 SuperSpeed** and **PCI Express Gen 1/2** via the **Intel PIPE 3.0** interface specification.

The 8b/10b encoding engine is a shared component between USB 3.0 and PCIe — both protocols use the same IBM-originated line code (Widmer & Franaszek, 1983). While the underlying encoding tables are identical, the two protocols assign **different roles and names** to the 12 special K-characters. This verification plan covers the encoder at the **PIPE abstraction level**, ensuring correct encoding of all 256 data symbols and all 12 legal K-codes regardless of which protocol is active above the PHY.

### 1.1 Scope
The verification environment targets the top-level encoder module `encoder_8b10b_top.sv` and its underlying 5B/6B (`encoder_5b6b_boolean.sv`) and 3B/4B (`encoder_3b4b_boolean.sv`) encoding sub-blocks.

### 1.2 Key Standards References
- **USB 3.0 Specification, Chapter 6 — Physical Layer**: Defines use of 8b/10b encoding for 5 Gbps SuperSpeed links. Specifies K-code assignments for packet framing (SHP, SDP, END, EDB, SLC, EPF), clock compensation (SKP), and symbol alignment (COM).
- **PCI Express Base Specification, Rev 2.0/3.0 — Chapter 4**: Defines use of 8b/10b encoding for 2.5/5.0 GT/s links. Specifies K-code assignments for framing (STP, END, EDB), skip (SKP), idle (IDL), FTS, PAD, and comma (COM).
- **Intel PIPE 3.0 Specification**: Defines the PHY Interface (`TxData`, `TxDataK`) used to pass 8-bit data and K-flag from MAC to PHY for encoding.
- **IEEE Std 802.3 Clause 36.2.4 / Widmer & Franaszek**: The original 8b/10b encoding tables (5B/6B and 3B/4B sub-blocks), running disparity rules, and special character definitions that both USB 3.0 and PCIe are derived from.

---

## 2. DUT Architecture & Interface Specification

### 2.1 Block Architecture
The 8b/10b encoder accepts an 8-bit byte (`in_data[7:0]`), a control symbol flag (`in_is_k`), and an input qualifier (`in_valid`). It partitions the input byte into:
- **5B sub-block**: Bits $[4:0]$ ($EDCBA$, decimal $x \in [0:31]$), encoded into a 6-bit code group ($abcdei$).
- **3B sub-block**: Bits $[7:5]$ ($HGF$, decimal $y \in [0:7]$), encoded into a 4-bit code group ($fghj$).

The two code groups are concatenated to form the 10-bit symbol:
$$\text{code10}[9:0] = \{ \text{code6}[5:0], \text{code4}[3:0] \} = \{ a, b, c, d, e, i, f, g, h, j \}$$

```
                +-------------------------------------------------------+
                |                  encoder_8b10b_top                    |
                |                                                       |
in_valid ------>|---+-------------------------+                         |
in_data[7:0] -->|---|--> [4:0] -> 5b6b_enc -> |                         |
in_is_k ------->|---|--> [7:5] -> 3b4b_enc -> |                         |
                |   |          (rd_mid)       |                         |
                |   +-------------------------+--> [Pipeline Register] -+--> out_data[9:0]
                |                                    (posedge clk)      |--> out_valid
                |                                                       |--> rd_positive
                |                                                       |--> invalid_k
clk ----------->|-------------------------------------------------------+
rst_n --------->|
                +-------------------------------------------------------+
```

### 2.2 Signal Port List
| Signal Name | Width | Direction | Clock Domain | Description |
| :--- | :---: | :---: | :---: | :--- |
| `clk` | 1 | Input | DUT | Symbol clock (250 MHz for USB3/PCIe Gen1 at 2.5/5.0 GT/s, or 500 MHz for Gen2). |
| `rst_n` | 1 | Input | Asynchronous | Active-low asynchronous reset, synchronously deasserted. |
| `in_valid` | 1 | Input | `clk` | Stimulus qualifier. When `1`, `in_data` and `in_is_k` are valid. |
| `in_data` | 8 | Input | `clk` | Input payload byte ($HGFEDCBA$). Maps to PIPE `TxData[7:0]`. |
| `in_is_k` | 1 | Input | `clk` | Special control symbol flag (`1` = K-character, `0` = Data). Maps to PIPE `TxDataK`. |
| `out_valid` | 1 | Output | `clk` | Output valid qualifier (registered). |
| `out_data` | 10 | Output | `clk` | Encoded 10-bit symbol (registered). |
| `invalid_k` | 1 | Output | `clk` | Illegal K-code error flag. Asserted when `in_is_k=1` for unsupported byte. |
| `rd_positive` | 1 | Output | `clk` | Current Running Disparity state after this symbol (`1` = $RD^+$, `0` = $RD^-$). |

### 2.3 Timing & Pipeline Latency
> The DUT incorporates a **1-cycle pipeline register** on its outputs (`out_data`, `out_valid`, `invalid_k`, `rd_positive`).  
> Stimulus driven on clock edge $T$ is evaluated combinationally through the 5B/6B and 3B/4B logic and latched into the output register at clock edge $T+1$.  
> **The UVM monitor must account for this 1-cycle latency by buffering cycle $T$ inputs to pair with cycle $T+1$ outputs.**

### 2.4 Reset Protocol
- `rst_n` asserted low asynchronously: outputs reset immediately (`out_valid <= 0`, `out_data <= 0`, `invalid_k <= 0`, `rd_positive <= 0`).
- Initial running disparity upon reset deassertion is defined as **negative running disparity** ($RD^-$, `rd_positive = 0`).

---

## 3. Functional Requirements & Feature Matrix

| ID | Feature Name | Requirement & Acceptance Description | Priority |
| :---: | :--- | :--- | :---: |
| **REQ-01** | **Data Byte Encoding** | All 256 byte values ($0x00$ to $0xFF$, $D.0.0$ to $D.31.7$) must produce legal 10-bit symbols matching the Widmer & Franaszek / IEEE 802.3 Table 36-1 encoding tables. | High |
| **REQ-02** | **Legal K-Characters** | All 12 legal K-characters (see Section 4) must encode correctly with `invalid_k = 0` and `out_valid = 1`. | High |
| **REQ-03** | **Illegal K-Character Detection** | Any input with `in_valid=1` and `in_is_k=1` that is not one of the 12 legal K-codes must assert `invalid_k = 1` and deassert `out_valid = 0`. | High |
| **REQ-04** | **Running Disparity ($RD$) Tracking** | The encoder must track disparity across 6-bit and 4-bit boundaries ($RD_{in} \to RD_{mid} \to RD_{out}$) to maintain DC balance. Disparity must flip on non-neutral sub-blocks and maintain state on neutral sub-blocks. | High |
| **REQ-05** | **Alternate .7 Encoding** | $D/K.x.7$ must correctly select the primary or alternate 4-bit representation based on $x$ and previous disparity $R$, per IEEE 802.3 Clause 36.2.4.4. | High |
| **REQ-06** | **Idle Cycle Handling** | When `in_valid = 0`, the output register must produce `out_valid = 0`, `invalid_k = 0`, and the running disparity state must be preserved without corruption. | Medium |
| **REQ-07** | **Back-to-Back Throughput** | The DUT must sustain 1 symbol/cycle continuous throughput when `in_valid = 1` across back-to-back cycles. | High |
| **REQ-08** | **Disparity Transitions** | All 4 possible running disparity transitions must occur and be verified: $RD^- \to RD^-$, $RD^- \to RD^+$, $RD^+ \to RD^+$, $RD^+ \to RD^-$. | High |
| **REQ-09** | **USB 3.0 K-Code Coverage** | All 8 USB 3.0 K-codes (COM, SKP, SDP, EDB, SUB, SHP, END, SLC, EPF) must be individually verified with correct encoding from both $RD^+$ and $RD^-$. | High |
| **REQ-10** | **PCIe K-Code Coverage** | All PCIe-used K-codes (COM, SKP, STP, END, EDB, IDL, FTS, PAD) must be individually verified with correct encoding from both $RD^+$ and $RD^-$. | High |
| **REQ-11** | **Comma Character Properties** | K28.5 (COM) must produce a unique comma pattern (`0011111xxx` / `1100000xxx`) that does not appear in any valid data symbol encoding, enabling receiver symbol alignment. | High |

---

## 4. Legal 8b/10b Special Characters (K-Codes) — USB 3.0 & PCIe Mapping

The 8b/10b coding scheme defines exactly 12 legal K-characters. Both USB 3.0 and PCIe use the same underlying encoding but assign different protocol-level names and roles. The encoder must support **all 12** regardless of which protocol is active — the protocol selection happens above the PIPE boundary.

| K-Code | Hex (`in_data`) | Sub-block $x.y$ | Binary ($HGF\_EDCBA$) | USB 3.0 Role | PCIe Role |
| :--- | :---: | :---: | :---: | :--- | :--- |
| **K28.0** | `8'h1C` | $28.0$ | `000_11100` | *Reserved* | *Reserved* |
| **K28.1** | `8'h3C` | $28.1$ | `001_11100` | **SKP** — Skip (clock compensation) | **FTS** — Fast Training Sequence |
| **K28.2** | `8'h5C` | $28.2$ | `010_11100` | **SDP** — Start Data Packet Payload | *Reserved* |
| **K28.3** | `8'h7C` | $28.3$ | `011_11100` | **EDB** — End Bad / Abort Packet | **IDL** — Idle |
| **K28.4** | `8'h9C` | $28.4$ | `100_11100` | **SUB** — Decode Error Substitution | *Reserved* |
| **K28.5** | `8'hBC` | $28.5$ | `101_11100` | **COM** — Comma (Symbol Alignment) | **COM** — Comma (Symbol Alignment) |
| **K28.6** | `8'hDC` | $28.6$ | `110_11100` | *Reserved* | *Reserved* |
| **K28.7** | `8'hFC` | $28.7$ | `111_11100` | *Reserved* | **EDB** — End Bad (Error in Data) |
| **K23.7** | `8'hF7` | $23.7$ | `111_10111` | **EPF** — End Packet Framing | **PAD** — Pad Character |
| **K27.7** | `8'hFB` | $27.7$ | `111_11011` | **SHP** — Start Header Packet | **STP** — Start TLP/DLLP |
| **K29.7** | `8'hFD` | $29.7$ | `111_11101` | **END** — End of Packet | **END** — End of Good Packet |
| **K30.7** | `8'hFE` | $30.7$ | `111_11110` | **SLC** — Start Link Command | *Reserved* |

### 4.1 USB 3.0 Ordered Sets Using These K-Codes
USB 3.0 SuperSpeed (Chapter 6) defines 4-symbol framing ordered sets with a **3-of-4 error tolerance** rule:

| Ordered Set | Symbol 0 | Symbol 1 | Symbol 2 | Symbol 3 | Function |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **HPSTART** | SHP (K27.7) | SHP (K27.7) | SHP (K27.7) | EPF (K23.7) | Start of Header Packet |
| **DPPSTART** | SDP (K28.2) | SDP (K28.2) | SDP (K28.2) | EPF (K23.7) | Start of Data Packet Payload |
| **DPPEND** | END (K29.7) | END (K29.7) | END (K29.7) | EPF (K23.7) | End of Data Packet Payload |
| **DPPABORT** | EDB (K28.3) | EDB (K28.3) | EDB (K28.3) | EPF (K23.7) | Abort / Nullify Data Packet |
| **LCSTART** | SLC (K30.7) | SLC (K30.7) | SLC (K30.7) | EPF (K23.7) | Start of Link Command |
| **SKP OS** | SKP (K28.1) | SKP (K28.1) | — | — | Clock Compensation (2 symbols) |

### 4.2 PCIe Ordered Sets Using These K-Codes
PCI Express defines its own ordered sets and framing sequences:

| Ordered Set | Lead Symbol | Function |
| :--- | :---: | :--- |
| **COM + SKP** | COM (K28.5) + SKP (K28.1) × N | Skip Ordered Set (clock compensation) |
| **COM + FTS** | COM (K28.5) + FTS (K28.1) × N | Fast Training Sequence |
| **COM + IDL** | COM (K28.5) + IDL (K28.3) × 3 | Electrical Idle Ordered Set |
| **STP** | STP (K27.7) | Start of Transaction/Data Link Layer Packet |
| **END** | END (K29.7) | End of Good Packet |
| **EDB** | EDB (K28.7) | End of Nullified/Bad Packet |
| **PAD** | PAD (K23.7) | Pad / Fill character |

### 4.3 Encoder Responsibility
The 8b/10b encoder operates below the protocol layer. It does **not** interpret ordered sets. Its sole responsibilities are:
1. Accept any byte on `in_data` with the `in_is_k` flag from the PIPE interface.
2. If `in_is_k=1` and the byte is one of the 12 legal K-codes → encode it and output `out_valid=1`.
3. If `in_is_k=1` and the byte is NOT one of the 12 legal K-codes → flag `invalid_k=1`, output `out_valid=0`.
4. If `in_is_k=0` → encode as a data symbol ($D.x.y$).
5. Maintain running disparity correctly across all symbols.

---

## 5. UVM Verification Architecture

### 5.1 Architecture Diagram

```
+-----------------------------------------------------------------------------------------+
|                                    encoder_tb_top.sv                                    |
|                                                                                         |
|   +--------------------------+                         +----------------------------+   |
|   | Clock & Reset Generator  |                         | DUT: encoder_8b10b_top     |   |
|   +--------------------------+                         +----------------------------+   |
|                 |                                                     ^                 |
|                 v                                                     |                 |
|   +-------------------------------------------------------------------+-------------+   |
|   |                          encoder_if (vif)                                       |   |
|   +---------------------------------------------------------------------------------+   |
|                 ^                                                     |                 |
|                 | (drv_cb)                                            | (mon_cb)        |
|                 |                                                     v                 |
|   +---------------------------------------------------------------------------------+   |
|   |                              encoder_env.svh                                    |   |
|   |                                                                                 |   |
|   |   +-----------------------------------------------------+                       |   |
|   |   |                  encoder_agent.svh                  |                       |   |
|   |   |                                                     |                       |   |
|   |   |   +-----------------------+                         |                       |   |
|   |   |   |  encoder_sequencer    |                         |                       |   |
|   |   |   +-----------------------+                         |                       |   |
|   |   |               |                                     |                       |   |
|   |   |               v                                     |                       |   |
|   |   |   +-----------------------+                         |                       |   |
|   |   |   |     encoder_driver    |                         |                       |   |
|   |   |   +-----------------------+                         |                       |   |
|   |   |                                                     |                       |   |
|   |   |                         +-----------------------+   |                       |   |
|   |   |                         |    encoder_monitor    |---|--------+              |   |
|   |   |                         +-----------------------+   |        |              |   |
|   |   +-----------------------------------------------------+        |              |   |
|   |                                                                  v              |   |
|   |                                          +----------------------------------+   |   |
|   |                                          | encoder_scoreboard (Golden Model)|   |   |
|   |                                          +----------------------------------+   |   |
|   |                                                                  |              |   |
|   |                                                                  v              |   |
|   |                                          +----------------------------------+   |   |
|   |                                          | encoder_coverage (Coverage Bins) |   |   |
|   |                                          +----------------------------------+   |   |
|   +---------------------------------------------------------------------------------+   |
+-----------------------------------------------------------------------------------------+
```

### 5.2 Package Organization & Strict File Naming Rule
To maintain clean modular separation between SystemVerilog source definitions and class declarations:
- All class files **must** end in `.svh` (`encoder_driver.svh`, `encoder_scoreboard.svh`, etc.).
- The package file `encoder_pkg.sv` includes all `.svh` files inside its `package ... endpackage` block.
- Only compilation units (`encoder_pkg.sv`), interfaces (`encoder_if.sv`), and modules (`encoder_tb_top.sv`) end in `.sv`.

---

## 6. UVM Component Specifications

### 6.1 Interface & Clocking Blocks (`encoder_if.sv`)
The interface must provide dedicated synchronous clocking blocks to prevent race conditions:
```systemverilog
interface encoder_if(input logic clk);
    logic       rst_n;
    logic       in_valid;
    logic [7:0] in_data;
    logic       in_is_k;
    logic       out_valid;
    logic [9:0] out_data;
    logic       rd_positive;
    logic       invalid_k;

    clocking drv_cb @(posedge clk);
        default input #1ps output #1ps;
        input  rst_n;
        output in_valid, in_data, in_is_k;
        input  out_valid, out_data, rd_positive, invalid_k;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1ps output #1ps;
        input rst_n, in_valid, in_data, in_is_k;
        input out_valid, out_data, rd_positive, invalid_k;
    endclocking

    modport DRV (clocking drv_cb, input clk);
    modport MON (clocking mon_cb, input clk);
    modport DUT (input clk, rst_n, in_valid, in_data, in_is_k,
                 output out_valid, out_data, rd_positive, invalid_k);
endinterface
```

---

### 6.2 Sequence Item (`encoder_seq_item.svh`)
The transaction item encapsulates all stimulus inputs and DUT outputs:
- **Stimulus Fields**: `in_data` (8-bit), `in_is_k` (1-bit), `in_valid` (1-bit).
- **Response Fields**: `out_data` (10-bit), `out_valid` (1-bit), `rd_positive` (1-bit), `invalid_k` (1-bit).
- **Enums & Tables**: `legal_k_e` enum containing all 12 valid K-character hex values.
- **Constraints**:
  - `c_valid`: Soft constraint defaulting `in_valid == 1`.
  - `c_k_dist`: Soft distribution giving 85% data symbols and 15% control symbols.
  - `c_legal_k`: If `in_is_k == 1`, `in_data` must be inside the 12 legal K codes.
- **Simulator Portability Function**: Provide a `randomize_item(bit legal_k_only=1, bit force_k=0)` fallback using `$urandom_range` to support toolchains without `svverification` licenses (e.g., Questa Starter FPGA Edition).

---

### 6.3 Sequence Library (`encoder_sequence.svh`)
The verification team must implement the following dedicated sequence classes derived from `encoder_base_seq`:

1. **`encoder_all_k_seq`** — All 12 Legal K-Characters:
   - Iterates deterministically through all 12 legal K-characters in order.
   - Sets `in_valid = 1`, `in_is_k = 1`, `in_data = K_CHAR[i]`.

2. **`encoder_all_data_seq`** — Exhaustive 256 Data Bytes:
   - Transmits all 256 data bytes ($0 \to 255$) with `in_valid = 1` and `in_is_k = 0`.

3. **`encoder_random_seq`** — Random Mixed Traffic:
   - Configurable iteration count (default: 200 items).
   - Generates mixed valid data bytes and K-characters.

4. **`encoder_illegal_k_seq`** — Illegal K-Character Detection:
   - Forces `in_valid = 1`, `in_is_k = 1`, and `in_data` NOT inside the 12 legal K-character codes.
   - Verifies the DUT's illegal symbol detection logic.

5. **`encoder_burst_seq`** — Burst & Idle:
   - Generates intermittent bursts (5 to 15 active cycles with `in_valid = 1`) followed by idle periods (2 to 6 cycles with `in_valid = 0`).
   - Verifies pipeline bubbling and running disparity state preservation across idle gaps.

6. **`encoder_usb3_ordered_set_seq`** — USB 3.0 Ordered Set Patterns:
   - Drives realistic USB 3.0 ordered set sequences:
     - **HPSTART**: K27.7, K27.7, K27.7, K23.7.
     - **DPPSTART**: K28.2, K28.2, K28.2, K23.7.
     - **DPPEND**: K29.7, K29.7, K29.7, K23.7.
     - **DPPABORT**: K28.3, K28.3, K28.3, K23.7.
     - **LCSTART**: K30.7, K30.7, K30.7, K23.7.
     - **SKP OS**: K28.1, K28.1.
   - Interleaves ordered sets with D-code payload data to simulate realistic USB 3.0 traffic patterns.
   - Verifies correct encoding and disparity tracking across ordered set boundaries.

7. **`encoder_pcie_ordered_set_seq`** — PCIe Ordered Set Patterns:
   - Drives realistic PCIe framing sequences:
     - **COM + SKP**: K28.5, K28.1, K28.1, K28.1.
     - **COM + IDL**: K28.5, K28.3, K28.3, K28.3.
     - **STP → Data → END**: K27.7, D-codes..., K29.7.
     - **STP → Data → EDB**: K27.7, D-codes..., K28.7.
   - Verifies correct comma pattern generation and disparity management during training.

---

### 6.4 Driver (`encoder_driver.svh`)
- Retrieves `virtual encoder_if` from `uvm_config_db`.
- Operates inside `run_phase` fetching items via `seq_item_port.get_next_item(req)`.
- Waits for `vif.drv_cb.rst_n == 1'b1` before driving.
- Drives `vif.drv_cb.in_valid`, `vif.drv_cb.in_data`, and `vif.drv_cb.in_is_k` synchronously on `@(vif.drv_cb)`.
- Calls `seq_item_port.item_done()` to complete the transaction handshake.

---

### 6.5 Monitor (`encoder_monitor.svh`)
The monitor must accurately reconstruct complete input-to-output transactions while respecting the 1-cycle pipeline latency.

**Monitor Latency Alignment Algorithm:**
```systemverilog
// Cycle T: Sample stimulus inputs
curr_valid = vif.mon_cb.in_valid;
curr_data  = vif.mon_cb.in_data;
curr_is_k  = vif.mon_cb.in_is_k;

// Cycle T: If previous cycle had stimulus, pair with current outputs
if (has_prev) begin
    item = encoder_seq_item::type_id::create("item");
    item.in_valid    = prev_valid;
    item.in_data     = prev_data;
    item.in_is_k     = prev_is_k;
    item.out_valid   = vif.mon_cb.out_valid;
    item.out_data    = vif.mon_cb.out_data;
    item.rd_positive = vif.mon_cb.rd_positive;
    item.invalid_k   = vif.mon_cb.invalid_k;
    mon_ap.write(item);
end

// Store current inputs for next cycle
prev_valid = curr_valid;
prev_data  = curr_data;
prev_is_k  = curr_is_k;
has_prev   = 1'b1;
```

---

### 6.6 Scoreboard Reference Model (`encoder_scoreboard.svh`)
The scoreboard contains a golden model reflecting the Widmer & Franaszek encoding tables:

#### Reference Model Algorithm:
1. **Disparity State Tracking**:
   Maintain `bit exp_rd`, initialized to `1'b0` ($RD^-$) upon reset.
2. **K-Character Validation**:
   Check if `item.in_is_k == 1`. If `item.in_data` is not within the 12 legal K codes:
   - Expected `out_valid = 1'b0`
   - Expected `invalid_k = 1'b1`
   - Disparity `exp_rd` remains unchanged.
3. **5B/6B Encoding ($EDCBA \to abcdei$)**:
   - Compute sub-block $x = \text{in\_data}[4:0]$.
   - Look up 6-bit code based on $x$ and `exp_rd`.
   - Compute intermediate disparity `rd_mid` based on disparity contribution of the 6-bit code (count of 1s vs 0s).
4. **3B/4B Encoding ($HGF \to fghj$)**:
   - Compute sub-block $y = \text{in\_data}[7:5]$.
   - Evaluate alternate .7 rule ($y=7$):
     $$\text{alt7} = (y == 7) \land [ \text{in\_is\_k} \lor (\text{rd\_mid} \land (x \in \{11, 13, 14\})) \lor (\neg\text{rd\_mid} \land (x \in \{17, 18, 20\})) ]$$
   - Evaluate K28 flip rule for $y \in \{1, 2, 5, 6\}$ when $x=28$ and $\neg\text{rd\_mid}$.
   - Look up 4-bit code based on $y$ and `rd_mid`.
   - Update final running disparity `exp_rd` based on disparity contribution of the 4-bit code.
5. **Comparison & Verification**:
   - Compare `item.out_data` against expected 10-bit code.
   - Compare `item.out_valid` against expected valid flag.
   - Compare `item.invalid_k` against expected error flag.
   - Compare `item.rd_positive` against expected running disparity `exp_rd`.
   - Increment match or mismatch counters and trigger `uvm_error` upon discrepancy.

---

### 6.7 Functional Coverage Model (`encoder_coverage.svh`)
The functional coverage model must measure the thoroughness of the test suite:

#### Covergroup Specification:
1. **`cp_in_data`** — Input Data Coverage:
   - 16 uniform bins covering the full range $[0x00 : 0xFF]$.
   - Corner cases: `all_zeroes` ($0x00$), `all_ones` ($0xFF$).
   - Walking ones: $0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80$.
   - Alternating patterns: $0x55, 0xAA$.
2. **`cp_in_is_k`** — Data vs Control:
   - `data_symbol` ($0$) and `ctrl_symbol` ($1$).
3. **`cp_legal_k`** — All 12 Legal K-Characters:
   - 12 individual bins for K28.0 through K30.7, sampled only when `in_is_k=1` and `in_valid=1`.
4. **`cp_usb3_k`** — USB 3.0 K-Code Subset:
   - 8 bins for the USB 3.0-active K-codes: COM (K28.5), SKP (K28.1), SDP (K28.2), EDB (K28.3), SUB (K28.4), SHP (K27.7), END (K29.7), SLC (K30.7), EPF (K23.7).
5. **`cp_pcie_k`** — PCIe K-Code Subset:
   - 7 bins for the PCIe-active K-codes: COM (K28.5), FTS (K28.1), IDL (K28.3), STP (K27.7), END (K29.7), EDB (K28.7), PAD (K23.7).
6. **`cp_invalid_k`** — Error Detection:
   - `no_error` ($0$) and `error` ($1$).
7. **`cp_rd_positive`** — Running Disparity State:
   - `rd_negative` ($0$) and `rd_positive` ($1$).
8. **`cp_rd_transition`** — Running Disparity Transitions:
   - Transition bins: $(0 \Rightarrow 0)$, $(0 \Rightarrow 1)$, $(1 \Rightarrow 1)$, $(1 \Rightarrow 0)$.
9. **Cross Coverage**:
   - `cross cp_in_data, cp_in_is_k` — data vs control distribution across data ranges.
   - `cross cp_legal_k, cp_rd_positive` — every legal K-character encoded from both $RD^-$ and $RD^+$.

**Dual-Mode Compatibility**: Protect SystemVerilog `covergroup` with `` `ifndef NO_SV_VERIFICATION ``. Provide an associative array / counter-based software tracker as a fallback so regressions can run on license-restricted simulators (like Questa Starter FPGA Edition) while still computing 100% functional coverage in `report_phase`.

---

## 7. Verification Test Suite Matrix

| Test Name | Targeted Sequences | Description & Verification Objective |
| :--- | :--- | :--- |
| `encoder_base_test` | Base sequence | Instantiates environment, validates configuration, checks reset release. |
| `encoder_random_test` | `encoder_random_seq` | 200 random mixed transactions; validates stability under arbitrary traffic. |
| `encoder_all_k_test` | `encoder_all_k_seq` | Transmits all 12 legal K-codes; verifies exact 10-bit symbol match and $RD$ behavior. |
| `encoder_all_data_test`| `encoder_all_data_seq` | Exhaustive 256 data byte test ($0x00 \to 0xFF$); verifies 100% data coverage. |
| `encoder_illegal_k_test`| `encoder_illegal_k_seq`| Injects 50 invalid K symbols; verifies `invalid_k=1` and `out_valid=0`. |
| `encoder_burst_test` | `encoder_burst_seq` | Alternates between bursts and idle periods; validates pipeline flushing and $RD$ hold. |
| `encoder_usb3_os_test` | `encoder_usb3_ordered_set_seq` | Drives USB 3.0 HPSTART, DPPSTART, DPPEND, DPPABORT, LCSTART, and SKP OS framing patterns interleaved with data payload. |
| `encoder_pcie_os_test` | `encoder_pcie_ordered_set_seq` | Drives PCIe COM+SKP, COM+IDL, STP→Data→END, STP→Data→EDB framing patterns. |
| `encoder_regression_test`| All sequences in series | Runs all stages sequentially for complete automated sign-off. |

---

## 8. Coverage & Exit Sign-Off Criteria

To achieve verification sign-off, the following criteria must be met:

1. **Zero Errors**:
   - `UVM_ERROR == 0`
   - `UVM_FATAL == 0`
   - Scoreboard mismatches $== 0$.
2. **Functional Coverage Requirements**:
   - **Data Byte Coverage**: $100\%$ (256/256 bytes hit).
   - **Legal K-Character Coverage**: $100\%$ (12/12 legal K codes hit).
   - **USB 3.0 K-Code Subset**: $100\%$ (all 8 USB 3.0 K-codes hit).
   - **PCIe K-Code Subset**: $100\%$ (all 7 PCIe K-codes hit).
   - **Running Disparity Transition Coverage**: $100\%$ (all 4 transitions hit).
   - **Cross: K-Code × RD**: $100\%$ (every K-code encoded from both $RD^+$ and $RD^-$).
   - **Illegal K Error Detection**: Verified and hit.
   - **Valid Signal Toggle**: Verified ($in\_valid$ asserted and deasserted).
   - **Overall Functional Coverage**: $> 99.5\%$.
3. **No Unknown States**: No `1'bx` or `1'bz` on `out_data`, `out_valid`, `rd_positive`, or `invalid_k` after reset release.

---

## 9. Compilation & Toolchain Guidelines

### 9.1 Simulator Command Reference (Questa / ModelSim)
```bash
# 1. Compile UVM DPI C backend with host GCC:
gcc -m64 -fPIC -shared -DQUESTA \
    -I$QUESTA_HOME/include \
    $QUESTA_HOME/verilog_src/uvm-1.2/src/dpi/uvm_dpi.cc -o uvm_dpi.so

# 2. Compile RTL, Packages, and Testbench:
vlog -sv -timescale 1ns/1ps +define+NO_SV_VERIFICATION \
    +incdir+$QUESTA_HOME/verilog_src/uvm-1.2/src +incdir+. \
    $QUESTA_HOME/verilog_src/uvm-1.2/src/uvm_pkg.sv \
    ../encoder_5b6b_if.sv ../encoder_3b4b_if.sv ../encoder_if.sv \
    ../encoder_5b6b_boolean.sv ../encoder_3b4b_boolean.sv ../encoder_8b10b_top.sv \
    encoder_pkg.sv encoder_tb_top.sv

# 3. Simulate:
vsim -c encoder_tb_top -sv_lib uvm_dpi -dpicpppath /usr/bin/gcc \
    -do "run -all; quit -f" +UVM_TESTNAME=encoder_regression_test
```

---

## 10. Summary Checklist for the Verification Engineer

- [ ] Ensure all class files use `.svh` extensions.
- [ ] Connect monitor to `mon_cb` and account for the 1-cycle pipeline latency between stimulus and response.
- [ ] Implement all 12 legal K-character checks and the illegal K-character rejection in the scoreboard.
- [ ] Implement running disparity tracking in the scoreboard adhering to the 5B/6B and 3B/4B disparity contribution rules.
- [ ] Add USB 3.0 ordered set sequence (`encoder_usb3_ordered_set_seq`) covering HPSTART, DPPSTART, DPPEND, DPPABORT, LCSTART, and SKP OS.
- [ ] Add PCIe ordered set sequence (`encoder_pcie_ordered_set_seq`) covering COM+SKP, COM+IDL, STP→Data→END, and STP→Data→EDB.
- [ ] Add coverage bins for USB 3.0 K-code subset (8 codes) and PCIe K-code subset (7 codes) in addition to the full 12-code coverage.
- [ ] Verify K28.5 (COM) comma uniqueness — the encoded bit pattern must not appear in any valid D-code encoding.
- [ ] Ensure `encoder_regression_test` achieves 100% functional coverage and 0 mismatches before committing code.

---

## Appendix A: Version History

| Version | Date | Changes |
| :---: | :--- | :--- |
| 1.0 | 2026-10-20 | Initial spec referencing IEEE 802.3 / ANSI X3.230 only. |
| 2.0 | 2026-10-20 | Updated to align with USB 3.0 SuperSpeed (Ch. 6) and PCIe (Ch. 4) standards. Added USB 3.0 and PCIe K-code role mapping table. Added ordered set sequence requirements (HPSTART, DPPSTART, DPPEND, DPPABORT, LCSTART, SKP OS for USB 3.0; COM+SKP, COM+IDL, STP, END, EDB for PCIe). Added protocol-specific coverage bins. Added comma uniqueness requirement (REQ-11). |
