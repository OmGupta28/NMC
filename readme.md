# Hybrid SRAM–MRAM Bit-Serial Compute Core for MAC

A small SystemVerilog prototype exploring a Maxwell-inspired compute core with an MRAM weight bank and an SRAM input/output bank.

This project tries to hide the MRAM latency for reading weights (BOs) using serial SRAM Bank accesses for inputs (IMOs)

## Scope

The current implementation evaluates a single compute core with operands defined during reset, therefore the operands are not written from an L2 source and does not test the MRAM write latency. **It does not implement the complete Maxwell architecture or end-to-end CNN inference (like obviously).**

- Three parallel bit-serial compute units (CFLs).
- One signed 5-bit broadcast operand (BO), representing a weight.
- Three unsigned 8-bit input memory operands (IMOs), representing inputs.
- One BO shared across the three CFLs.
- Separate accumulators for the three computation streams.
- Behavioral SRAM and MRAM models with fixed access delays.


## Architecture

The MRAM bank supplies the BO, while the SRAM bank supplies a distinct IMO to each CFL. Since the SRAM interface supplies one IMO at a time, the three IMOs are collected sequentially.
The SRAM read/write latency is assumed to be single cycle and MRAM read latency is considered 3x of SRAM's read and write latency 10x of that of SRAM's.

The MRAM read is initiated during operand collection. If the BO arrives before computation begins, its longer read latency does not add an additional stall to this phase.

| Component | Current configuration |
|---|---|
| Compute units | 3 CFLs |
| BO precision | 5-bit signed |
| IMO precision | 8-bit unsigned |
| Accumulator width | 32 bits |
| RTL memory capacity | 32 × 8 bits per bank |
| SRAM read latency | 1 modeled cycle |
| MRAM read latency | 3 modeled cycles |
| MRAM write latency | 10 modeled cycles |
| Operand loading | Sequential IMOs; shared BO |


## Computation Schedule

The current RTL simulation gives the following schedule:

| Phase | Cycles |
|---|---:|
| Collect three IMOs and obtain the BO | 4 |
| Bit-serial computation | 6 |
| Result Collection and restart | 1 |
| **Total per group of three MACs** | **11** |

This equals to:

- **3/11 ≈ 0.273 MACs per cycle**

These values describe the current resident-operand schedule. They exclude initial memory population, L2 transfers, and final output transfers.


## Memory Modeling with NVSim

NVSim is used separately to estimate memory-bank area, access latency, dynamic access energy, and static (leakage) power.

The NVSim experiments use larger banks than the current RTL prototype:

- RTL: **32 bytes per bank**
- NVSim: **4 KB and 8 KB per bank**

Hence the following results are memory-model estimates at selected capacity points, not physical implementation results for the complete RTL core.

### Modeling Configuration

**Only theh changes made in the .cfg file are mentioned here**
| Parameter | Setting |
|---|---|
| Process node | 45 nm |
| MRAM cell model | sample_STTRAM.cell |
| SRAM cell model | SRAM.cell |
| Access width | 8 bits |
| Optimization objective | Read latency |
| Bank organization | 1 × 1 |
| Mat organization | 1 × 1 |
| Sense-amplifier mux | 16 |
| Output mux levels | 1, 1 |


### Individual Bank Results: 4 KB

| Metric | MRAM | SRAM |
|---|---:|---:|
| Area | 7,367.094 µm² | 11,782.763 µm² |
| Read latency | 1.029 ns | 0.329552 ns |
| Write latency | 10.203 ns | 0.329552 ns |
| Read dynamic energy | 1.805 pJ/access | 2.288 pJ/access |
| Write dynamic energy | 8.683 pJ/access | 0.428 pJ/access |
| Leakage power | 2.220 mW | 6.052 mW |

### Individual Bank Results: 8 KB

| Metric | MRAM | SRAM |
|---|---:|---:|
| Area | 12,594.030 µm² | 22,841.294 µm² |
| Read latency | 1.066 ns | 0.436092 ns |
| Write latency | 10.253 ns | 0.436092 ns |
| Read dynamic energy | 1.847 pJ/access | 4.104 pJ/access |
| Write dynamic energy | 9.009 pJ/access | 0.604 pJ/access |
| Leakage power | 4.312 mW | 12.012 mW |

### Hybrid vs. All-SRAM Memory 

The baseline contains two SRAM banks. The hybrid configuration replaces one with an equally sized MRAM bank.

| Metric | 4 KB per bank | 8 KB per bank |
|---|---:|---:|
| Total capacity | 8 KB | 16 KB |
| All-SRAM area | 23,565.526 µm² | 45,682.588 µm² |
| Hybrid area | 19,149.857 µm² | 35,435.324 µm² |
| **Area reduction** | **18.74%** | **22.43%** |
| All-SRAM leakage | 12.104 mW | 24.024 mW |
| Hybrid leakage | 8.272 mW | 16.324 mW |
| **Leakage reduction** | **31.66%** | **32.05%** |

These only include the memory models (Not the computing core and accumulation modules).

## Observations

- The modeled hybrid memory subsystem occupies less area and has lower leakage than the all-SRAM baseline at both tested capacities.
- MRAM reads consume less dynamic energy in these configurations, while writes consume much more energy and take longer.
- The current schedule provides an opportunity to overlap the BO read with sequential IMO collection.
- The modeled area reduction increases from 18.74% to 22.43% between the two tested capacities. Additional capacity points are needed to establish a broader trend.
- In some cases, the sequential IMO accesses might become a bottleneck (Cores with Single CFL like Maxwell). Maxwell would be a better choice here because there would be minimal latency hiding to deal with.

>The modeled latency in nanoseconds must be converted to cycles using the chosen clock period and interface timing. A three-cycle RTL delay is an assumption, not a direct NVSim output.


## Reproducing the Results

### RTL Simulation

Requirements: 

Just Run it on Vivado and view the waveforms

### NVSim

From the NVSim directory, using the supplied configuration and cell files:

```bash
make the changes mentioned above in the .cfg file
refer the readme of NVSim given in the references 
```

## What I could do Next

- Verify the all-SRAM baseline under the same computation schedule.
- Decouple operand capture from fixed timing using explicit response-valid signals.
- Sweep BO precision, CFL count, and memory latency.
- Count memory accesses and estimate energy over a defined workload.
- Include weight-tile refill and output-write costs.
- Explore an all-MRAM configuration.

## References

- [Maxwell](https://www.isqed.org/English/Proceedings/pdf/3B-3-112.pdf)
- [HH-PIM](https://arxiv.org/abs/2504.01468)
- [NVSim](https://github.com/SEAL-UCSB/NVSim)
- [Overflow-free Compute Memories for Edge AI Acceleration](https://www.researchgate.net/publication/373810046_Overflow-free_Compute_Memories_for_Edge_AI_Acceleration)
