using System.Text.Json;

namespace Memoria.NeverwinterNights.Toolset;

internal static class AoeSimulator
{
    private const double Radius = 6.67;
    private const double CastTime = 2.5;
    private const double ProjectileSpeed = 20.0;
    private const double AllyMargin = 0.75;
    private const double EngagementDistance = 2.0;
    private const double RecheckInterval = 0.5;
    private const double StationarySpeed = 0.5;

    private readonly record struct Point(double X, double Y)
    {
        public static Point operator +(Point left, Point right) => new(left.X + right.X, left.Y + right.Y);
        public static Point operator -(Point left, Point right) => new(left.X - right.X, left.Y - right.Y);
        public static Point operator *(Point value, double scale) => new(value.X * scale, value.Y * scale);
    }

    private sealed record Agent(string Name, string Team, Point Position, Point Velocity, bool Engaged = false, double VelocityChangeAt = -1.0, Point? VelocityAfter = null);

    private sealed record Expectations(int MinimumInitialHits = 0, bool SafeStarts = false, bool VerySafeCancels = false, bool StationaryWaits = false, bool StationaryEventuallyStarts = false);

    private sealed record Scenario(string Name, Point Caster, Agent[] Agents, int MinimumTargets = 3, Expectations? Expected = null);

    private sealed record Result(string Scenario, double Radius, double ImpactTime, Point Aim, string[] EnemiesHit, string[] AlliesAtRisk, bool Safe);

    private sealed record PolicyResult(string Mode, string Decision, double? StartsAt, double? CancelledAt, int EnemiesHitAtImpact, string[] AlliesAtRiskAtImpact, bool RoundLostToCancellation);

    public static int Run(string[] arguments)
    {
        if (arguments.Length != 1)
        {
            Console.Error.WriteLine("aoe-sim: specify exactly one output JSON file.");
            return 1;
        }

        Scenario[] scenarios = BuildScenarios();
        object[] scenarioReports = scenarios.Select(BuildScenarioReport).ToArray();
        var report = new { model = new { spell = "Fireball", radiusMetres = Radius, castTimeSeconds = CastTime, projectileSpeedMetresPerSecond = ProjectileSpeed, allySafetyMarginMetres = AllyMargin, engagementDistanceMetres = EngagementDistance, recheckSeconds = RecheckInterval, stationarySpeedMetresPerSecond = StationarySpeed, prediction = "constant velocity; first hostile contact clamp; circle intersections; ally-aware shifts; swept ally segment; piecewise actual velocity for policy regression tests" }, scenarios = scenarioReports };
        string output = Path.GetFullPath(arguments[0]);
        Directory.CreateDirectory(Path.GetDirectoryName(output)!);
        File.WriteAllText(output, JsonSerializer.Serialize(report, new JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine($"AoE simulation: {scenarios.Length} scenarios -> {output}");
        int failures = 0;
        foreach (Scenario scenario in scenarios)
        {
            Result initial = FindBest(scenario, scenario.MinimumTargets, true);
            PolicyResult safe = SimulateSafe(scenario, initial);
            PolicyResult verySafe = SimulateVerySafe(scenario, initial);
            PolicyResult stationary = SimulateStationary(scenario);
            string failure = Validate(scenario, initial, safe, verySafe, stationary);
            Console.WriteLine($"{scenario.Name}: initial={(initial.Safe ? $"safe/{initial.EnemiesHit.Length}" : "none")}, safe={safe.Decision}, very-safe={verySafe.Decision}, stationary={stationary.Decision}{failure}");
            if (failure.Length > 0) failures++;
        }

        return failures == 0 ? 0 : 2;
    }

    private static object BuildScenarioReport(Scenario scenario)
    {
        Result safePlan = FindBest(scenario, scenario.MinimumTargets, true);
        return new { scenario.Name, scenario.Caster, scenario.Agents, scenario.MinimumTargets, scenario.Expected, initialSafePlan = safePlan, unrestrictedPlan = FindBest(scenario, scenario.MinimumTargets, false), policies = new[] { SimulateSafe(scenario, safePlan), SimulateVerySafe(scenario, safePlan), SimulateStationary(scenario) } };
    }

    private static Scenario[] BuildScenarios()
    {
        return
        [
            new Scenario("approach", new Point(0, 0), [new Agent("ally-a", "ally", new Point(6, -1), new Point(2.8, 0)), new Agent("ally-b", "ally", new Point(5, 2), new Point(2.6, -0.2)), new Agent("enemy-a", "enemy", new Point(22, -2), new Point(-2.3, 0.1)), new Agent("enemy-b", "enemy", new Point(23, 1), new Point(-2.4, 0)), new Agent("enemy-c", "enemy", new Point(25, 3), new Point(-2.5, -0.2))]),
            new Scenario("melee", new Point(0, 0), [new Agent("ally-a", "ally", new Point(15, 0), new Point(0, 0), true), new Agent("ally-b", "ally", new Point(17, 3), new Point(0, 0), true), new Agent("enemy-a", "enemy", new Point(16, 1), new Point(0, 0), true), new Agent("enemy-b", "enemy", new Point(18, 2), new Point(0, 0), true), new Agent("enemy-c", "enemy", new Point(14, -2), new Point(0.3, 0), true)]),
            new Scenario("reinforcements", new Point(0, 0), [new Agent("ally-a", "ally", new Point(14, 0), new Point(0, 0), true), new Agent("ally-b", "ally", new Point(15, 3), new Point(0, 0), true), new Agent("engaged-enemy", "enemy", new Point(15, 1), new Point(0, 0), true), new Agent("reinforcement-a", "enemy", new Point(29, -4), new Point(-1.5, 0.1)), new Agent("reinforcement-b", "enemy", new Point(30, -1), new Point(-1.6, 0)), new Agent("reinforcement-c", "enemy", new Point(31, 2), new Point(-1.4, -0.1))]),
            new Scenario("caster-at-cluster-edge", new Point(0, 0), [new Agent("enemy-a", "enemy", new Point(5, -2), new Point(0.3, 0)), new Agent("enemy-b", "enemy", new Point(6, 1), new Point(0.2, 0)), new Agent("enemy-c", "enemy", new Point(8, 3), new Point(0.1, -0.1)), new Agent("enemy-d", "enemy", new Point(9, -1), new Point(0.2, 0.1))]),
            new Scenario("monk-stops-at-front-line", new Point(0, 0), [new Agent("monk", "ally", new Point(4, 0), new Point(3, 0)), new Agent("front-enemy", "enemy", new Point(9, 0), new Point(0, 0)), new Agent("rear-a", "enemy", new Point(13, -2), new Point(0, 0)), new Agent("rear-b", "enemy", new Point(14, 2), new Point(0, 0)), new Agent("rear-c", "enemy", new Point(17, -1), new Point(0, 0)), new Agent("rear-d", "enemy", new Point(18, 2), new Point(0, 0))], 4, new Expectations(4, true, false, true, true)),
            new Scenario("fast-monk-stops-at-front-line", new Point(0, -5), [new Agent("fast-monk", "ally", new Point(3, 0), new Point(6, 0)), new Agent("front-enemy", "enemy", new Point(9, 0), new Point(0, 0)), new Agent("rear-a", "enemy", new Point(13, -3), new Point(0, 0)), new Agent("rear-b", "enemy", new Point(13, 3), new Point(0, 0)), new Agent("rear-c", "enemy", new Point(17, -2), new Point(0, 0)), new Agent("rear-d", "enemy", new Point(17, 2), new Point(0, 0))], 4, new Expectations(4, true, false, true, true)),
            new Scenario("two-monks-different-speeds", new Point(0, -6), [new Agent("regular-monk", "ally", new Point(2, -2), new Point(2.8, 0.2)), new Agent("very-fast-monk", "ally", new Point(2, 3), new Point(6.5, -0.3)), new Agent("front-a", "enemy", new Point(10, -2), new Point(0, 0)), new Agent("front-b", "enemy", new Point(10, 3), new Point(0, 0)), new Agent("rear-a", "enemy", new Point(14, -3), new Point(0, 0)), new Agent("rear-b", "enemy", new Point(14, 1), new Point(0, 0)), new Agent("rear-c", "enemy", new Point(17, 3), new Point(0, 0))], 4, new Expectations(4, true, false, true, true)),
            new Scenario("fast-monk-late-turns-into-blast", new Point(0, -8), [new Agent("fast-monk", "ally", new Point(3, -8), new Point(5.5, 0), false, 0.75, new Point(2.0, 5.5)), new Agent("enemy-a", "enemy", new Point(14, -2), new Point(0, 0)), new Agent("enemy-b", "enemy", new Point(15, 1), new Point(0, 0)), new Agent("enemy-c", "enemy", new Point(17, -1), new Point(0, 0)), new Agent("enemy-d", "enemy", new Point(18, 2), new Point(0, 0)), new Agent("enemy-e", "enemy", new Point(20, 0), new Point(0, 0))], 4, new Expectations(4, true, true, true, false)),
            new Scenario("fast-monk-stops-before-cast", new Point(0, -7), [new Agent("fast-monk", "ally", new Point(4, -6), new Point(6, 0), false, 1.0, new Point(0, 0)), new Agent("enemy-a", "enemy", new Point(15, -2), new Point(0, 0)), new Agent("enemy-b", "enemy", new Point(16, 1), new Point(0, 0)), new Agent("enemy-c", "enemy", new Point(18, -1), new Point(0, 0)), new Agent("enemy-d", "enemy", new Point(19, 2), new Point(0, 0))], 4, new Expectations(4, true, false, true, true))
        ];
    }

    private static PolicyResult SimulateSafe(Scenario scenario, Result initial)
    {
        if (!initial.Safe) return new PolicyResult("safe", "does not start: no initially safe point", null, null, 0, [], false);
        (string[] enemies, string[] allies) = ActualImpact(scenario, initial.Aim, initial.ImpactTime);
        return new PolicyResult("safe", allies.Length == 0 ? "casts without post-start cancellation" : "commits cast despite a later ally trajectory change", 0.0, null, enemies.Length, allies, false);
    }

    private static PolicyResult SimulateVerySafe(Scenario scenario, Result initial)
    {
        if (!initial.Safe) return new PolicyResult("very-safe", "does not start: no initially safe point", null, null, 0, [], false);
        for (double elapsed = RecheckInterval; elapsed < initial.ImpactTime; elapsed += RecheckInterval)
        {
            Scenario snapshot = SnapshotScenario(scenario, elapsed);
            double remaining = initial.ImpactTime - elapsed;
            Agent[] enemies = snapshot.Agents.Where(agent => agent.Team == "enemy").ToArray();
            string[] risk = snapshot.Agents.Where(agent => agent.Team == "ally" && DistanceToSegment(initial.Aim, agent.Position, PredictFriendlyEndpoint(agent, enemies, remaining, EngagementDistance)) <= Radius + AllyMargin).Select(agent => agent.Name).ToArray();
            if (Distance(initial.Aim, snapshot.Caster) <= Radius + AllyMargin) risk = risk.Append("caster").ToArray();
            if (risk.Length > 0) return new PolicyResult("very-safe", $"cancels at {elapsed:F1}s: {string.Join(", ", risk)} may enter", 0.0, elapsed, 0, risk, true);
        }

        (string[] hit, string[] atRisk) = ActualImpact(scenario, initial.Aim, initial.ImpactTime);
        return new PolicyResult("very-safe", "casts; all rechecks remain safe", 0.0, null, hit.Length, atRisk, false);
    }

    private static PolicyResult SimulateStationary(Scenario scenario)
    {
        const double maximumWait = 6.0;
        for (double elapsed = 0.0; elapsed <= maximumWait; elapsed += RecheckInterval)
        {
            Scenario snapshot = SnapshotScenario(scenario, elapsed);
            bool moving = snapshot.Agents.Any(agent => agent.Team == "ally" && Speed(agent.Velocity) > StationarySpeed);
            if (moving) continue;
            Result plan = FindBest(snapshot, snapshot.MinimumTargets, true);
            if (!plan.Safe) continue;
            (string[] hit, string[] atRisk) = ActualImpact(scenario, plan.Aim, elapsed + plan.ImpactTime);
            string decision = elapsed <= 0.0 ? "casts immediately: allies stationary" : $"waits, then casts at {elapsed:F1}s after allies stop";
            return new PolicyResult("stationary", decision, elapsed, null, hit.Length, atRisk, false);
        }

        return new PolicyResult("stationary", "waits: allies do not become stationary within 6.0s", null, null, 0, [], false);
    }

    private static string Validate(Scenario scenario, Result initial, PolicyResult safe, PolicyResult verySafe, PolicyResult stationary)
    {
        Expectations? expected = scenario.Expected;
        if (expected is null) return "";
        List<string> failures = [];
        if (initial.EnemiesHit.Length < expected.MinimumInitialHits) failures.Add($"initial hits {initial.EnemiesHit.Length} < {expected.MinimumInitialHits}");
        if ((safe.StartsAt is not null) != expected.SafeStarts) failures.Add("safe start mismatch");
        if ((verySafe.CancelledAt is not null) != expected.VerySafeCancels) failures.Add("very-safe cancellation mismatch");
        if ((stationary.StartsAt is null || stationary.StartsAt > 0.0) != expected.StationaryWaits) failures.Add("stationary wait mismatch");
        if ((stationary.StartsAt is not null) != expected.StationaryEventuallyStarts) failures.Add("stationary eventual start mismatch");
        return failures.Count == 0 ? "" : $" [FAIL: {string.Join("; ", failures)}]";
    }

    private static Result FindBest(Scenario scenario, int minimumTargets, bool requireSafety)
    {
        Agent[] enemies = scenario.Agents.Where(agent => agent.Team == "enemy").ToArray();
        Agent[] allies = scenario.Agents.Where(agent => agent.Team == "ally").Append(new Agent("caster", "ally", scenario.Caster, new Point(0, 0), true)).ToArray();
        Point[] predicted = enemies.Select(enemy => Predict(enemy, CastTime + Distance(scenario.Caster, enemy.Position) / ProjectileSpeed)).ToArray();
        List<Point> seeds = predicted.ToList();
        for (int enemyIndex = 0; enemyIndex < predicted.Length; enemyIndex++)
        {
            Point enemy = predicted[enemyIndex];
            Point closestAlly = allies.Select(ally => ClosestPointOnSegment(enemy, ally.Position, PredictFriendlyEndpoint(ally, enemies, CastTime + Distance(scenario.Caster, enemy) / ProjectileSpeed, EngagementDistance))).OrderBy(point => Distance(point, enemy)).First();
            double allyDistance = Distance(enemy, closestAlly);
            if (allyDistance > 0.01) seeds.Add(enemy + (enemy - closestAlly) * (Radius * 0.98 / allyDistance));
        }

        for (int left = 0; left < predicted.Length; left++)
        {
            for (int right = left + 1; right < predicted.Length; right++)
            {
                Point delta = predicted[right] - predicted[left];
                double distance = Distance(predicted[left], predicted[right]);
                if (distance <= 0.01 || distance > Radius * 2.0) continue;
                Point midpoint = (predicted[left] + predicted[right]) * 0.5;
                double height = Math.Sqrt(Radius * Radius - distance * distance * 0.25);
                Point perpendicular = new(-delta.Y / distance, delta.X / distance);
                seeds.Add(midpoint);
                seeds.Add(midpoint + perpendicular * height);
                seeds.Add(midpoint - perpendicular * height);
            }
        }

        Result? best = null;
        foreach (Point seed in seeds)
        {
            Point aim = seed;
            double impactTime = CastTime + Distance(scenario.Caster, aim) / ProjectileSpeed;
            string[] hit = enemies.Where(enemy => Distance(Predict(enemy, impactTime), aim) <= Radius).Select(enemy => enemy.Name).ToArray();
            string[] risk = allies.Where(agent => DistanceToSegment(aim, agent.Position, PredictFriendlyEndpoint(agent, enemies, impactTime, EngagementDistance)) <= Radius + AllyMargin).Select(agent => agent.Name).ToArray();
            bool safe = risk.Length == 0;
            Result candidate = new(scenario.Name, Radius, impactTime, aim, hit, risk, safe);
            if (hit.Length < minimumTargets || requireSafety && !safe) continue;
            if (best is null || hit.Length > best.EnemiesHit.Length || hit.Length == best.EnemiesHit.Length && risk.Length < best.AlliesAtRisk.Length || hit.Length == best.EnemiesHit.Length && risk.Length == best.AlliesAtRisk.Length && impactTime < best.ImpactTime) best = candidate;
        }

        return best ?? new Result(scenario.Name, Radius, 0, scenario.Caster, [], [], false);
    }

    private static Scenario SnapshotScenario(Scenario scenario, double elapsed)
    {
        Agent[] enemies = scenario.Agents.Where(agent => agent.Team == "enemy").ToArray();
        Agent[] agents = scenario.Agents.Select(agent => SnapshotAgent(agent, enemies, elapsed)).ToArray();
        return scenario with { Agents = agents };
    }

    private static Agent SnapshotAgent(Agent agent, Agent[] enemies, double elapsed)
    {
        (Point position, Point velocity) = ActualState(agent, enemies, elapsed);
        return agent with { Position = position, Velocity = velocity, Engaged = Speed(velocity) <= 0.001, VelocityChangeAt = -1.0, VelocityAfter = null };
    }

    private static (string[] Enemies, string[] Allies) ActualImpact(Scenario scenario, Point aim, double impactAt)
    {
        Agent[] enemies = scenario.Agents.Where(agent => agent.Team == "enemy").ToArray();
        string[] hit = enemies.Where(enemy => Distance(ActualState(enemy, enemies, impactAt).Position, aim) <= Radius).Select(enemy => enemy.Name).ToArray();
        string[] risk = scenario.Agents.Where(agent => agent.Team == "ally" && Distance(ActualState(agent, enemies, impactAt).Position, aim) <= Radius + AllyMargin).Select(agent => agent.Name).ToArray();
        if (Distance(scenario.Caster, aim) <= Radius + AllyMargin) risk = risk.Append("caster").ToArray();
        return (hit, risk);
    }

    private static (Point Position, Point Velocity) ActualState(Agent agent, Agent[] enemies, double elapsed)
    {
        if (agent.Engaged) return (agent.Position, new Point(0, 0));
        if (agent.Team != "ally") return (RawPosition(agent, elapsed), VelocityAt(agent, elapsed));
        const double step = 0.025;
        for (double time = 0.0; time <= elapsed; time += step)
        {
            Point position = RawPosition(agent, time);
            Agent? contact = enemies.FirstOrDefault(enemy => Distance(position, RawPosition(enemy, time)) <= EngagementDistance);
            if (contact is not null)
            {
                double low = Math.Max(0.0, time - step);
                double high = time;
                for (int iteration = 0; iteration < 20; iteration++)
                {
                    double middle = (low + high) * 0.5;
                    if (Distance(RawPosition(agent, middle), RawPosition(contact, middle)) <= EngagementDistance) high = middle;
                    else low = middle;
                }

                return (RawPosition(agent, high), new Point(0, 0));
            }
        }

        return (RawPosition(agent, elapsed), VelocityAt(agent, elapsed));
    }

    private static Point RawPosition(Agent agent, double elapsed)
    {
        if (agent.Engaged) return agent.Position;
        if (agent.VelocityChangeAt < 0.0 || elapsed <= agent.VelocityChangeAt) return agent.Position + agent.Velocity * elapsed;
        return agent.Position + agent.Velocity * agent.VelocityChangeAt + (agent.VelocityAfter ?? agent.Velocity) * (elapsed - agent.VelocityChangeAt);
    }

    private static Point VelocityAt(Agent agent, double elapsed)
    {
        if (agent.Engaged) return new Point(0, 0);
        return agent.VelocityChangeAt >= 0.0 && elapsed > agent.VelocityChangeAt ? agent.VelocityAfter ?? agent.Velocity : agent.Velocity;
    }

    private static Point Predict(Agent agent, double seconds) => agent.Position + agent.Velocity * seconds;
    private static double Speed(Point velocity) => Math.Sqrt(velocity.X * velocity.X + velocity.Y * velocity.Y);
    private static double Distance(Point left, Point right) => Math.Sqrt((left.X - right.X) * (left.X - right.X) + (left.Y - right.Y) * (left.Y - right.Y));

    private static Point PredictFriendlyEndpoint(Agent ally, Agent[] enemies, double seconds, double engagementDistance)
    {
        double stopTime = seconds;
        foreach (Agent enemy in enemies)
        {
            Point relativePosition = ally.Position - enemy.Position;
            Point relativeVelocity = ally.Velocity - enemy.Velocity;
            double a = relativeVelocity.X * relativeVelocity.X + relativeVelocity.Y * relativeVelocity.Y;
            double b = 2.0 * (relativePosition.X * relativeVelocity.X + relativePosition.Y * relativeVelocity.Y);
            double c = relativePosition.X * relativePosition.X + relativePosition.Y * relativePosition.Y - engagementDistance * engagementDistance;
            if (c <= 0.0) stopTime = 0.0;
            else if (a > 0.0001)
            {
                double discriminant = b * b - 4.0 * a * c;
                if (discriminant >= 0.0)
                {
                    double contactTime = (-b - Math.Sqrt(discriminant)) / (2.0 * a);
                    if (contactTime >= 0.0 && contactTime < stopTime) stopTime = contactTime;
                }
            }
        }

        return Predict(ally, stopTime);
    }

    private static Point ClosestPointOnSegment(Point point, Point start, Point end)
    {
        Point delta = end - start;
        double lengthSquared = delta.X * delta.X + delta.Y * delta.Y;
        if (lengthSquared <= double.Epsilon) return start;
        double projection = Math.Clamp(((point.X - start.X) * delta.X + (point.Y - start.Y) * delta.Y) / lengthSquared, 0.0, 1.0);
        return start + delta * projection;
    }

    private static double DistanceToSegment(Point point, Point start, Point end) => Distance(point, ClosestPointOnSegment(point, start, end));
}
