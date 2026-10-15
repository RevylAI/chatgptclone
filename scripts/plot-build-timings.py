#!/usr/bin/env python3
"""Render the recorded Revyl measurements; requires matplotlib."""

import csv
from pathlib import Path
from statistics import median

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


ROOT = Path(__file__).resolve().parents[1] / "evidence" / "build-time"
with (ROOT / "measurements.csv").open() as source:
    runs = list(csv.DictReader(source))

plt.rcParams.update({"font.family": "DejaVu Sans", "font.size": 11})
fig, axes = plt.subplots(1, 2, figsize=(11, 5.5))
colors = ["#64748b", "#0d9488"]
groups = [
    [r for r in runs if r["variant"] == "control-baseline"],
    [r for r in runs if r["variant"] == "control-optimized"],
]
assert all(groups), "Both controlled variants must be recorded"

for ax, key, title in zip(
    axes,
    ["xcode_seconds", "total_seconds"],
    ["Xcode build step", "Remote build total"],
):
    values = [[float(r[key]) for r in group] for group in groups]
    centers = [median(v) for v in values]
    ax.bar([0, 1], centers, color=colors, width=0.55)
    for i, samples in enumerate(values):
        offsets = [(j - (len(samples) - 1) / 2) * 0.09 for j in range(len(samples))]
        ax.scatter([i + x for x in offsets], samples, s=42, color="#0f172a", zorder=3)
        ax.text(i, max(samples) + 1.2, f"{centers[i]:.1f}s", ha="center", weight="bold", fontsize=15)
    reduction = 100 * (1 - centers[1] / centers[0])
    ax.set_title(f"{title}\n{reduction:.1f}% lower median", loc="left", pad=18, weight="bold")
    ax.set_xticks([0, 1], [f"Baseline\nn={len(groups[0])}", f"Optimized\nn={len(groups[1])}"])
    ax.set_ylabel("Seconds · lower is better")
    ax.set_ylim(0, max(map(max, values)) * 1.25)
    ax.spines[["top", "right"]].set_visible(False)
    ax.set_axisbelow(True)
    ax.grid(axis="y", alpha=0.15)

fig.suptitle("ChatGPT Swift demo · Revyl cloud builds", x=0.07, ha="left", fontsize=19, weight="bold")
fig.text(0.07, 0.045, "Bars: medians. Dots: every controlled run. Both variants use --no-cache.\nTotal includes project preparation, Xcode, packaging/upload and runner overhead; excludes queue and device install.", fontsize=10, color="#475569")
fig.subplots_adjust(top=0.73, bottom=0.22, left=0.07, right=0.98, wspace=0.3)
fig.savefig(ROOT / "comparison.png", dpi=180, facecolor="white")
plt.close(fig)

fig, ax = plt.subplots(figsize=(12, 6))
x = list(range(len(runs)))
ax.plot(x, [float(r["total_seconds"]) for r in runs], "o-", color="#64748b", label="Remote build total", linewidth=1.5)
ax.plot(x, [float(r["xcode_seconds"]) for r in runs], "o-", color="#0d9488", label="Xcode step", linewidth=1.5)
ax.set_xticks(x, [r["label"] for r in runs], rotation=40, ha="right", fontsize=9)
ax.set_ylabel("Seconds · lower is better")
ax.set_ylim(bottom=0)
ax.set_title("Every measured iteration, including rejected experiments", loc="left", fontsize=17, weight="bold", pad=20)
ax.spines[["top", "right"]].set_visible(False)
ax.grid(axis="y", alpha=0.15)
ax.legend(frameon=False)
fig.text(0.07, 0.02, "Exploratory runs have different cache conditions. See measurements.csv and README for each run's configuration.", fontsize=9, color="#475569")
fig.subplots_adjust(bottom=0.35, left=0.07, right=0.98, top=0.87)
fig.savefig(ROOT / "iterations.png", dpi=180, facecolor="white")
