using System.Text.Json;

namespace PortfolioSamples.Noga;

public sealed record MatchEvaluation(
    decimal LlmScore,
    string FitCategory,
    string Recommendation,
    string[] WhyMatch,
    string[] WhyNot,
    string[] RiskNotes,
    string[] Badges,
    bool ApprovedForDelivery);

public static class MatchEvaluationNormalizer
{
    public static MatchEvaluation FromModelJson(string modelJson)
    {
        using var document = JsonDocument.Parse(modelJson);
        var root = document.RootElement;

        return new MatchEvaluation(
            LlmScore: Clamp(ReadDecimal(root, "score", 0), 0, 1),
            FitCategory: NormalizeCategory(ReadString(root, "fit_category", "not_recommended")),
            Recommendation: ReadString(root, "recommendation", "Review manually before pursuing."),
            WhyMatch: ReadStringArray(root, "why_match"),
            WhyNot: ReadStringArray(root, "why_not"),
            RiskNotes: ReadStringArray(root, "risk_notes"),
            Badges: ReadStringArray(root, "badges"),
            ApprovedForDelivery: ReadBool(root, "approved_for_delivery", false));
    }

    private static string NormalizeCategory(string value)
    {
        return value.Trim().ToLowerInvariant() switch
        {
            "direct_match" or "direct match" => "direct_match",
            "business_opportunity" or "business opportunity" => "business_opportunity",
            _ => "not_recommended"
        };
    }

    private static string[] ReadStringArray(JsonElement root, string propertyName)
    {
        if (!root.TryGetProperty(propertyName, out var property) || property.ValueKind != JsonValueKind.Array)
        {
            return Array.Empty<string>();
        }

        return property
            .EnumerateArray()
            .Where(item => item.ValueKind == JsonValueKind.String)
            .Select(item => item.GetString())
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Select(value => value!.Trim())
            .Take(8)
            .ToArray();
    }

    private static string ReadString(JsonElement root, string propertyName, string fallback)
    {
        return root.TryGetProperty(propertyName, out var property) && property.ValueKind == JsonValueKind.String
            ? property.GetString()?.Trim() ?? fallback
            : fallback;
    }

    private static decimal ReadDecimal(JsonElement root, string propertyName, decimal fallback)
    {
        if (!root.TryGetProperty(propertyName, out var property))
        {
            return fallback;
        }

        return property.ValueKind switch
        {
            JsonValueKind.Number when property.TryGetDecimal(out var value) => value,
            JsonValueKind.String when decimal.TryParse(property.GetString(), out var value) => value,
            _ => fallback
        };
    }

    private static bool ReadBool(JsonElement root, string propertyName, bool fallback)
    {
        return root.TryGetProperty(propertyName, out var property) && property.ValueKind == JsonValueKind.True
            ? true
            : root.TryGetProperty(propertyName, out property) && property.ValueKind == JsonValueKind.False
                ? false
                : fallback;
    }

    private static decimal Clamp(decimal value, decimal min, decimal max)
    {
        return Math.Min(Math.Max(value, min), max);
    }
}

