def map_priority(p):
    p = p.lower()
    if p in ["highest", "blocker"]:
        return 5
    elif p in ["high", "critical"]:
        return 4
    elif p in ["medium", "major"]:
        return 3
    elif p in ["low", "minor"]:
        return 2
    elif p in ["lowest", "trivial"]:
        return 1
    else:
        return 3  # fallback
