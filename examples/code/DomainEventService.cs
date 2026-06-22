using System.Text.Json;
using Npgsql;
using NpgsqlTypes;

namespace PortfolioSamples.Noga;

public sealed record DomainEventEnvelope(
    string EventType,
    string AggregateType,
    Guid AggregateId,
    Guid? ClientId,
    object Payload);

public sealed class DomainEventService
{
    private readonly string _connectionString;

    public DomainEventService(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<Guid> PublishAsync(DomainEventEnvelope envelope, CancellationToken cancellationToken = default)
    {
        const string sql = """
            insert into domain_events (
                event_type,
                aggregate_type,
                aggregate_id,
                client_id,
                payload
            )
            values (
                @event_type,
                @aggregate_type,
                @aggregate_id,
                @client_id,
                @payload::jsonb
            )
            returning id;
            """;

        await using var connection = new NpgsqlConnection(_connectionString);
        await connection.OpenAsync(cancellationToken);

        await using var command = new NpgsqlCommand(sql, connection);
        command.Parameters.AddWithValue("event_type", envelope.EventType);
        command.Parameters.AddWithValue("aggregate_type", envelope.AggregateType);
        command.Parameters.AddWithValue("aggregate_id", envelope.AggregateId);
        command.Parameters.AddWithValue("client_id", NpgsqlDbType.Uuid, envelope.ClientId ?? (object)DBNull.Value);
        command.Parameters.AddWithValue("payload", JsonSerializer.Serialize(envelope.Payload));

        var result = await command.ExecuteScalarAsync(cancellationToken);
        return (Guid)result!;
    }
}

