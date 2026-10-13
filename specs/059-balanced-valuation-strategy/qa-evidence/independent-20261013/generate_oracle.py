"""Independent exact acceptance oracle; no application code imports."""
import json
import random
from fractions import Fraction

METRICS = [
    "goals", "assists", "shots_on_target", "tackles", "interceptions",
    "saves", "goals_conceded", "yellow_cards", "red_cards",
]


def fixed(value):
    scaled = value * 1_000_000
    quotient, remainder = divmod(abs(scaled.numerator), scaled.denominator)
    quotient += 2 * remainder >= scaled.denominator
    sign = "-" if scaled < 0 and quotient else ""
    return f"{sign}{quotient // 1_000_000}.{quotient % 1_000_000:06d}"


def rational(parts):
    sign, coefficient, exponent = parts
    return sign * coefficient * Fraction(10) ** exponent


rng = random.Random(23059)
vectors = []
for mask in range(1, 512):
    weights, references, features = {}, {}, {}
    score = Fraction()
    for n, metric in enumerate(METRICS, 1):
        if mask & (1 << (n - 1)):
            weight = [rng.choice([-1, 1]), rng.randrange(0, 1_000_001),
                      rng.choice([-12, -7, -6, -2, 0, 2, 15])]
            reference = [1, rng.randrange(1, 301), rng.choice([-2, -1, 0, 1])]
            feature = fixed(min(Fraction(n) / rational(reference), Fraction(1)))
            weights[metric] = weight
            references[metric] = reference
            features[metric] = feature
            score += rational(weight) * Fraction(feature)
    vectors.append({"weights": weights, "references": references,
                    "features": features, "score": fixed(score)})

print(json.dumps(vectors, sort_keys=True, separators=(",", ":")))
