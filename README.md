# 8-bit Single-Cycle Processor with Memory Hierarchy

## Repository Name

**simple-processor-memory-hierarchy**

## Description

An advanced continuation of the single-cycle 8-bit processor project, implementing data memory, data cache, and instruction cache to build a complete memory hierarchy system in Verilog HDL.

---

## Overview

This repository extends the simple processor developed in Lab 5 by adding a full **memory hierarchy**. It demonstrates how data and instruction memory subsystems are integrated into a single-cycle CPU to improve performance using **caching mechanisms**. The project is implemented entirely in **Verilog HDL** and tested using timing simulations.

Each part of this lab builds upon the previous design, progressively enhancing the CPU with realistic memory structures and cache operations.

---

## Part 1 – Data Memory

### Objective

To integrate a **data memory module** with the previously built CPU and implement new memory access instructions.

### Implemented Instructions

* **lwd** – Load data from memory using register direct addressing.
* **lwi** – Load data from memory using immediate addressing.
* **swd** – Store data to memory using register direct addressing.
* **swi** – Store data to memory using immediate addressing.

### Features

* 256-byte data memory implemented using 8-bit registers.
* Memory latency simulated with artificial delays (#40 time units).
* Memory access signals: `ADDRESS`, `WRITEDATA`, `READDATA`, `READ`, `WRITE`, and `BUSYWAIT`.
* CPU stalls automatically when `BUSYWAIT` is asserted to ensure correct synchronization.

### Testing

The CPU was tested with multiple load and store instruction sequences. Timing diagrams validated the correct stalling behavior and memory access flow.

---

## Part 2 – Data Cache

### Objective

To introduce a **data cache** between the CPU and main memory to reduce access latency and improve performance.

### Design Details

* **Cache Type:** Direct-mapped
* **Cache Size:** 32 Bytes (8 blocks × 4 Bytes)
* **Word Size:** 1 Byte per word
* **Write Policy:** Write-back
* **Replacement Policy:** Direct-mapped eviction with dirty bit

### Features

* Implements **valid**, **dirty**, and **tag** bits for each cache block.
* Artificial timing delays for realistic simulation (tag comparison = #0.9, indexing = #1).
* Handles **read-hit**, **write-hit**, **read-miss**, and **write-miss** conditions.
* Supports **write-back** and **block replacement** mechanisms.
* Finite State Machine (FSM) used for cache miss handling.

### Testing

Cache behavior was verified using memory access-intensive programs. Performance was compared to the cache-less CPU from Part 1, demonstrating reduced stalls and faster execution in hit scenarios.

---

## Part 3 – Instruction Cache and Memory

### Objective

To add an **instruction cache and instruction memory** subsystem, completing the full memory hierarchy for the CPU.

### Design Details

* **Cache Type:** Direct-mapped
* **Cache Size:** 128 Bytes (8 blocks × 16 Bytes)
* **Instruction Word Size:** 4 Bytes
* **Memory Size:** 1024 Bytes (256 instructions)
* **Write Policy:** Read-only (no dirty bit needed)

### Features

* Separate instruction cache and memory modules.
* Tag, valid bits, and index-based mapping.
* Artificial delays for indexing (#1), tag comparison (#0.9), and word selection (#1).
* BUSYWAIT mechanism stalls CPU on instruction cache misses.
* 81-cycle miss penalty for realistic timing simulation.

### Testing

Instruction cache and memory were validated with various instruction sequences. The CPU successfully fetched and executed instructions through the cache, stalling only during cache misses.

---

## Tools and Environment

* **Language:** Verilog HDL
* **Simulation Tools:** ModelSim / GTKWave
* **Assembler:** CO224Assembler (C-based)
* **Platform:** Linux-based environment

---

## Folder Structure

```
├── part1/                 # Data Memory Integration (lwd, lwi, swd, swi)
├── part2/                 # Data Cache Design and FSM Controller
├── part3/                 # Instruction Cache and Memory Integration
├── LICENSE                # License file
├── README.md              # Project documentation
└── Report.pdf             # Detailed report of implementation and results
```

---

## License

This project is released under the **MIT License**. See the [LICENSE](./LICENSE) file for more details.

---

## Author

**Tharaka Dilshan**

Department of Computer Engineering, University of Peradeniya

This project demonstrates the practical application of **computer architecture concepts** by integrating memory and cache systems into a single-cycle CPU. It reflects my ability to design, implement, and analyze hardware-level systems and memory hierarchies for efficient processor performance.
