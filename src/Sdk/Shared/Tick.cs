using System;
using System.Runtime.InteropServices;

namespace Sdk.Shared;

/// <summary>
/// A single tick price update. Layout is sequential and packed for zero‑copy binary I/O (exactly 32 bytes).
/// </summary>
[StructLayout(LayoutKind.Sequential, Pack = 8)]
public readonly struct Tick : IEquatable<Tick>
{
    private const long SyntheticFlag = unchecked((long)0x8000_0000_0000_0000UL);

    private readonly long _timeAndFlags;

    /// <summary>Bid price.</summary>
    public readonly double Bid;

    /// <summary>Ask price.</summary>
    public readonly double Ask;

    /// <summary>Tick volume.</summary>
    public readonly double Volume;

    /// <summary>Initializes a new instance of the <see cref="Tick"/> struct.</summary>
    public Tick(long time, double bid, double ask, double volume, bool isSynthetic = false)
    {
        _timeAndFlags = (time & ~SyntheticFlag) | (isSynthetic ? SyntheticFlag : 0L);
        Bid = bid;
        Ask = ask;
        Volume = volume;
    }

    /// <summary>Timestamp in 100‑ns ticks.</summary>
    public long Time => _timeAndFlags & ~SyntheticFlag;

    /// <summary>True if this tick was synthesised (e.g., from bar data).</summary>
    public bool IsSynthetic => (_timeAndFlags & SyntheticFlag) != 0;

    /// <inheritdoc/>
    public override bool Equals(object? obj) => obj is Tick other && Equals(other);

    /// <inheritdoc/>
    public bool Equals(Tick other) =>
        Time == other.Time && Bid == other.Bid && Ask == other.Ask && Volume == other.Volume && IsSynthetic == other.IsSynthetic;

    /// <inheritdoc/>
    public override int GetHashCode() => HashCode.Combine(Time, Bid, Ask, Volume, IsSynthetic);

    /// <summary>Equality operator.</summary>
    public static bool operator ==(Tick left, Tick right) => left.Equals(right);

    /// <summary>Inequality operator.</summary>
    public static bool operator !=(Tick left, Tick right) => !left.Equals(right);
}
