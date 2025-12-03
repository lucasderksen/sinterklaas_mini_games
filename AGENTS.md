// ❌ Old (Deprecated)
Colors.blue.withOpacity(0.5)
backgroundColor.withOpacity(0.8)

// ✅ New (Recommended)
Colors.blue.withValues(alpha: 0.5)
backgroundColor.withValues(alpha: 0.8)