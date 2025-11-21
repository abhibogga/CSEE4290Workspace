import matplotlib.pyplot as plt

# ======================================================
# Replace with YOUR real single miss-rate numbers
# exe_time[assoc][block][cache_size] = miss_rate
# ======================================================
#art exetime
exe_time = {
    2: {
        16:  {16: 21747942, 32: 21747342, 64: 21299022, 128: 20740206},
        32:  {16: 20128556, 32: 20127956, 64: 20041736, 128: 19934542},
        64:  {16: 18124798, 32: 18119164, 64: 18117738, 128: 18117738},
        128: {16: 14278580, 32: 14267962, 64: 14265346, 128: 14265346}
    },
    4: {
        16:  {16: 21746742, 32: 21746742, 64: 21651342, 128: 20734746},
        32:  {16: 20127356, 32: 20127356, 64: 20109356, 128: 19932862},
        64:  {16: 18117738, 32: 18117738, 64: 18117738, 128: 18117738},
        128: {16: 14265346, 32: 14265346, 64: 14265346, 128: 14265346}
    },
    8: {
        16:  {16: 21746742, 32: 21746742, 64: 21746742, 128: 20727366},
        32:  {16: 20127356, 32: 20127356, 64: 20127356, 128: 19930822},
        64:  {16: 18117738, 32:  18117738, 64:  18117738, 128:  18117738},
        128: {16: 14265346, 32: 14265346, 64: 14265346, 128: 14265346} #maybe rerun this line?
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

        # Extract single miss-rate values in cache-size order
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

plt.legend(title="Configurations", fontsize=10)
plt.grid(True, linestyle="--", alpha=0.4)
plt.tight_layout()
plt.show()
