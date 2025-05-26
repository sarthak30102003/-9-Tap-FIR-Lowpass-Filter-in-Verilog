# 🎚️ 9-Tap FIR Lowpass Filter in Verilog

A pipelined and fully synthesizable **9-tap FIR Lowpass Filter** implemented in Verilog, tested with synthesized sine waves using **CORDIC IP cores** in **Vivado 2023.1.** This design filters a noisy signal (containing both 2 MHz and 30 MHz components) and attenuates the high-frequency part, preserving the desired 2 MHz sine wave.

---

## 🔧 Features

- ✅ **Lowpass FIR filter** with symmetric 9-tap structure
- ⚙️ **Cutoff Frequency:** ~10 MHz
- ⏱️ **Sampling Frequency:** 100 MHz
- 📊 Tested with **CORDIC-generated sine waves:**
  - 2 MHz (desired signal)
  - 30 MHz (high-frequency noise)
- 📘 Fully pipelined for performance
- ✅ Verified through behavioral simulation

---

## 📁 File Structure
```
fir-lowpass-filter/
├── src/
│   └── fir.v
├── sim/
│   ├── fir_tb.v
│   ├── fir_filter_waveform.png
│   ├── fir_filter_schematic.png
|   ├── cordic_ip/  
│   └── detailed_schematic.pdf      
└── README.md
```


---

## 📷 Waveform Snapshot

![Simulation Waveform]() <!-- Replace with actual path if uploading -->

---

## 🧪 How It Works

- **CORDIC IP cores** are used to generate two sine waves:
  - `sin_2MHz` synthesized with `phase_inc = 200`
  - `sin_30MHz` synthesized with `phase_inc = 3000`

- These are combined and downsampled to 100 MHz:
  `noisy_signal = (sin_2MHz + sin_30MHz) / 2`

- The **noisy_signal** is passed to the FIR filter.
- The **filtered_signal** removes the 30 MHz noise while preserving the 2 MHz sine wave.

### Filter Architecture
- **Symmetric 9-Tap FIR FIlter**
- Multiply-accumulate operation pipelined across four stages
- Uses pre-defined 16-bit fixed-point coefficients

---

## 🧠 FIR Coefficients (Windowed Sinc)
 ```
reg signed [15:0] coeff [0:8] = { 16'h04F6,
                                  16'h0AE4,
                                  16'h1089,
                                  16'h1496,
                                  16'h160F,
                                  16'h1469,
                                  16'h1089,
                                  16'h0AE4,
                                  16'h04F6
};
``` 

## ✅ Simulation Tool

- **Vivado 2023.1**
- **CORDIC IP Core** for sine wave synthesis
- **Vivado Waveform viewer** for signal visualization 

---

🧰 Concepts Covered
- FIR filter design and pipelined implementation
- CORDIC-based sine wave generation in Verilog
- Clock-domain management and signal resampling
- Behavioral simulation and waveform verification

---

## 👨‍💻 Author

**Sarthak Aggarwal**  
📘 B.Tech ECE, Delhi Technological University  
🔗 [LinkedIn](https://www.linkedin.com/in/sarthak-aggarwal-486b60240/)  
📧 [sarthakaggarwal30102003@gmail.com]

---



