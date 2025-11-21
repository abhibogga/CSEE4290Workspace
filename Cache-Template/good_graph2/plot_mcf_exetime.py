import matplotlib.pyplot as plt

# ======================================================
# exe_time[assoc][block][cache_size] = execution_time (cycles)
# The data below is consolidated from the separate blocks provided
# in the previous turn to create one valid Python dictionary.
# ======================================================
#mcf
exe_time = {
    # Associativity = 2
    2: {
        # Block Size 16
        16:  {16: 137131384, 32: 134238566, 64: 130737792, 128: 128899820},
        # Block Size 32
        32:  {16: 114923032, 32: 113515118, 64: 110585894, 128: 108387792},
        # Block Size 64
        64:  {16: 94063086, 32: 93470714, 64: 91234732, 128: 88133734},
        # Block Size 128
        128: {16: 70300882, 32: 69859492, 64: 69177304, 128: 67223256}
    },
    # Associativity = 4
    4: {
        # Block Size 16
        16: {16: 137092138, 32: 133995254, 64: 129523122, 128: 128392492},
        # Block Size 32
        32: {16: 114889660, 32: 113660680, 64: 109770916, 128: 107734142},
        # Block Size 64
        64: {16: 94044178, 32: 93450474, 64: 91807804, 128: 87190480},
        # Block Size 128
        128: {16: 70257778, 32: 69797754, 64: 69370084, 128: 67199308}
    },
    # Associativity = 8
    8: {
        # Block Size 16
        16: {16: 136998402, 32: 134136812, 64: 128879486, 128: 128303008},
        # Block Size 32
        32: {16: 114875464, 32: 113899240, 64: 109114146, 128: 107461922},
        # Block Size 64
        64: {16: 94053346, 32: 93432424, 64: 92546344, 128: 86284982},
        # Block Size 128
        128: {16: 70254756, 32: 69787458, 64: 69329152, 128: 67631122}
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
        # NOTE: If you are plotting 'Miss Rate' as stated in the title,
        # you need to ensure the values in exe_time are actually miss rates,
        # not execution cycles. The Y-axis label needs to match the data type.
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
# DOUBLE CHECK THIS LABEL: If the data is execution time, change 'Miss Rate' to 'Execution Time (Cycles)'
plt.ylabel("Exe time", fontsize=12) 
plt.title("Exe time vs Cache Size\n(Color = Associativity, Line Style = Block Size)", fontsize=14)

plt.legend(title="Configurations", fontsize=10)
plt.grid(True, linestyle="--", alpha=0.4)
plt.tight_layout()
plt.show()
