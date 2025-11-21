import matplotlib.pyplot as plt

# ======================================================
# exe_time[assoc][block][cache_size] = execution_time (cycles)
# Updated with user-provided data for Associativity 2, 4, and 8
# ======================================================
#swim exetime
exe_time = {
    # Associativity = 2
    2: {
        # Block Size 16
        16: {16: 21744660, 32: 21744190, 64: 21742058, 128: 18517478},
        # Block Size 32
        32: {16: 13374990, 32: 13374756, 64: 13373540, 128: 11761294},
        # Block Size 64
        64: {16: 9190188, 32: 9190038, 64: 9189280, 128: 8383248},
        # Block Size 128
        128: {16: 7097788, 32: 7097664, 64: 7097136, 128: 6694164}
    },
    # Associativity = 4
    4: {
        # Block Size 16
        16: {16: 21744838, 32: 21743958, 64: 20133398, 128: 18519444},
        # Block Size 32
        32: {16: 13375078, 32: 13374638, 64: 12570110, 128: 11762548},
        # Block Size 64
        64: {16: 9190200, 32: 9189980, 64: 8788480, 128: 8384114},
        # Block Size 128
        128: {16: 7097746, 32: 7097634, 64: 6897636, 128: 6694852}
    },
    # Associativity = 8
    8: {
        # Block Size 16
        16: {16: 21744824, 32: 21743948, 64: 21742366, 128: 16904598},
        # Block Size 32
        32: {16: 13375072, 32: 13374634, 64: 13373842, 128: 10954074},
        # Block Size 64
        64: {16: 9190196, 32: 9189978, 64: 9189582, 128: 7978860},
        # Block Size 128
        128: {16: 7097742, 32: 7097634, 64: 7097436, 128: 6491206}
    }
}

cache_sizes = [16, 32, 64, 128]
associativities = list(exe_time.keys())
block_sizes = list(list(exe_time.values())[0].keys())

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
        # Extract execution time values in cache-size order
        y = [exe_time[assoc][blk][cs] for cs in cache_sizes]

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
plt.ylabel("Exe time", fontsize=12)
plt.title("Exe time vs Cache Size\n(Color = Associativity, Line Style = Block Size)", fontsize=14)

# Moved legend outside to prevent it from covering data
plt.legend(title="Configurations", fontsize=10, bbox_to_anchor=(1.05, 1), loc='upper left')
plt.grid(True, linestyle="--", alpha=0.4)
plt.tight_layout()
plt.show()
