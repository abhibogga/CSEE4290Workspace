import matplotlib.pyplot as plt

# ======================================================
# Replace with YOUR real single miss-rate numbers
# miss_rates[assoc][block][cache_size] = miss_rate
# ======================================================

miss_rates = {
    2: {
        16:  {16: 0.3, 32: 0.27, 64: 0.26, 128: 0.25},
        32:  {16: 0.25, 32: 0.25, 64: 0.24, 128: 0.24},
        64:  {16: 0.22, 32: 0.22, 64: 0.22, 128: 0.21},
        128: {16: 0.16, 32: 0.16, 64: 0.15, 128: 0.15}
    },
    4: {
        16:  {16: 0.27, 32: 0.27, 64: 0.26, 128: 0.24},
        32:  {16: 0.25, 32: 0.25, 64: 0.24, 128: 0.23},
        64:  {16: 0.22, 32: 0.22, 64: 0.21, 128: 0.21},
        128: {16: 0.16, 32: 0.16, 64: 0.15, 128: 0.15}
    },
    8: {
        16:  {16: 0.27, 32: 0.27, 64: 0.25, 128: 0.23},
        32:  {16: 0.25, 32: 0.25, 64: 0.24, 128: 0.23},
        64:  {16: 0.22, 32: 0.22, 64: 0.21, 128: 0.21},
        128: {16: 0.18, 32: 0.16, 64: 0.15, 128: 0.15}
    }
}

cache_sizes = [16, 32, 64, 128]
associativities = list(miss_rates.keys())
block_sizes = list(list(miss_rates.values())[0].keys())

# ======================================================
# Plotting setup
# ======================================================
plt.figure(figsize=(10, 6))

colors = {2: "green", 4: "red", 8: "purple"}

line_styles = {
    16: "-",
    32: "--",
    64: ":",
    128: "-."
}

# ======================================================
# Generate curves: one point per cache size
# ======================================================
for assoc in associativities:
    for blk in block_sizes:

        # Extract single miss-rate values in cache-size order
        y = [miss_rates[assoc][blk][cs] for cs in cache_sizes]

        plt.plot(
            cache_sizes,
            y,
            color=colors[assoc],
            linestyle=line_styles[blk],
            linewidth=2,
            label=f"Assoc={assoc}, Block={blk}"
        )

# ======================================================
# Labeling
# ======================================================
plt.xlabel("Cache Size (KB)", fontsize=12)
plt.ylabel("Miss Rate", fontsize=12)
plt.title("Miss Rate vs Cache Size\n(Color = Associativity, Line Style = Block Size)", fontsize=14)

plt.legend(title="Configurations", fontsize=10)
plt.grid(True, linestyle="--", alpha=0.4)
plt.tight_layout()
plt.show()
