import matplotlib.pyplot as plt

# ======================================================
# Replace with YOUR real single miss-rate numbers
# miss_rates[assoc][block][cache_size] = miss_rate
# ======================================================

miss_rates = {
    2: {
        16:  {16: 0.54, 32: 0.54, 64: 0.52, 128: 0.51},
        32:  {16: 0.44, 32: 0.44, 64: 0.43, 128: 0.42},
        64:  {16: 0.34, 32: 0.34, 64: 0.33, 128: 0.32},
        128: {16: 0.24, 32: 0.23, 64: 0.23, 128: 0.22}
    },
    4: {
        16:  {16: 0.55, 32: 0.54, 64: 0.53, 128: 0.51},
        32:  {16: 0.44, 32: 0.44, 64: 0.43, 128: 0.42},
        64:  {16: 0.35, 32: 0.34, 64: 0.34, 128: 0.33},
        128: {16: 0.25, 32: 0.23, 64: 0.23, 128: 0.22}
    },
    8: {
        16:  {16: 0.55, 32: 0.54, 64: 0.53, 128: 0.52},
        32:  {16: 0.44, 32: 0.44, 64: 0.43, 128: 0.43},
        64:  {16: 0.35, 32: 0.35, 64: 0.34, 128: 0.33},
        128: {16: 0.25, 32: 0.25, 64: 0.23, 128: 0.23}
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
