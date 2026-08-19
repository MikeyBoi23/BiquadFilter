import matplotlib.pyplot as plt
from fixedpoint import FixedPoint

sampling_rate = 44100
filename = r"<PATH TO FILE>"

samples = []
time = []                     # for x‑axis in seconds

idx = 0
with open(filename, 'r') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('//'):
            continue
        q_properties = {'signed': True, 'm': 2, 'n': 14}
        fp_num = FixedPoint(f'0x{line}', **q_properties)  # Parse the raw 2Q14 bits back to a float
        samples.append(float(fp_num))
        time.append(idx / sampling_rate)
        idx += 1

# Plot the full output
plt.figure(figsize=(14, 5))
plt.plot(time, samples, linewidth=0.8)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('FPGA Biquad Filter Output (50 Hz recovered tone)')
plt.grid(True, alpha=0.3)

# Zoom in on the first 100 ms to see the waveform clearly
zoom_limit = 0.1  # seconds
zoom_time = [t for t in time if t <= zoom_limit]
zoom_samples = samples[:len(zoom_time)]

plt.figure(figsize=(14, 5))
plt.plot(zoom_time, zoom_samples, linewidth=0.8)
plt.xlabel('Time (s)')
plt.ylabel('Amplitude')
plt.title('Zoom: First 100 ms of FPGA Output')
plt.grid(True, alpha=0.3)

plt.show()
