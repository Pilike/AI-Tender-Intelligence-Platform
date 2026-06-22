namespace PortfolioSamples.Noga;

public sealed record ExtractorRequest(
    string SourceId,
    string SourceUrl,
    string RawHtml,
    IReadOnlyDictionary<string, string> ExtractionHints);

public sealed record ExtractedTender(
    string Title,
    string? BuyerName,
    DateOnly? PublishDate,
    DateTimeOffset? DeadlineAt,
    string? SourceItemKey,
    string? DetailUrl,
    IReadOnlyList<ExtractedDocument> Documents,
    decimal Confidence,
    IReadOnlyList<string> Warnings);

public sealed record ExtractedDocument(
    string FileName,
    string SourceUrl,
    string? ContentType);

public interface ITenderExtractor
{
    Task<ExtractedTender> ExtractAsync(ExtractorRequest request, CancellationToken cancellationToken = default);
}

