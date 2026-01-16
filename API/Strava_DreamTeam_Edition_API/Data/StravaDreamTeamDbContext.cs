using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Strava_DreamTeam_Edition_API.Models.Domain;
namespace Strava_DreamTeam_Edition_API.Data
{
    public class StravaDreamTeamDbContext : DbContext
    {
        public StravaDreamTeamDbContext(DbContextOptions<StravaDreamTeamDbContext> options) : base(options)
        {

        }

        public DbSet<Activity> Activities { get; set; }

        public DbSet<ActivityCategory> ActivityCategories{ get; set; }

        public DbSet<UserProfile> UserProfiles { get; set; } = default!;

        public DbSet<FriendRelation> FriendRelations { get; set; } = default!;

        public DbSet<ActivityGpsPoint> activityGpsPoints { get; set; } = default!;
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            
            modelBuilder.Entity<FriendRelation>()
            .HasIndex(x => new { x.UserId, x.OtherUserId })
            .IsUnique();

            modelBuilder.Entity<ActivityCategory>().HasData(
                new ActivityCategory
                {
                    ID = Guid.Parse("11111111-1111-1111-1111-111111111111"),
                    Name = "Bieg"
                },
                new ActivityCategory
                {
                    ID = Guid.Parse("22222222-2222-2222-2222-222222222222"),
                    Name = "Rower"
                },
                new ActivityCategory
                {
                    ID = Guid.Parse("33333333-3333-3333-3333-333333333333"),
                    Name = "Spacer"
                },
                new ActivityCategory
                {
                    ID = Guid.Parse("44444444-4444-4444-4444-444444444444"),
                    Name = "Hiking"
                },
                new ActivityCategory
                {
                    ID = Guid.Parse("55555555-5555-5555-5555-555555555555"),
                    Name = "Trening siłowy"
                }
            );

            modelBuilder.Entity<UserProfile>().HasData(
                new UserProfile { UserId = "10000000-0000-0000-0000-000000000002", FirstName = "Jan", LastName = "Kowalski", Gender = "M", HeightCm = 178, WeightKg = 76, BirthDate = new DateTime(1994, 2, 10), UpdatedAt = DateTime.UtcNow },
                new UserProfile { UserId = "10000000-0000-0000-0000-000000000003", FirstName = "Anna", LastName = "Nowak", Gender = "F", HeightCm = 168, WeightKg = 60, BirthDate = new DateTime(1996, 6, 5), UpdatedAt = DateTime.UtcNow },
                new UserProfile { UserId = "10000000-0000-0000-0000-000000000004", FirstName = "Piotr", LastName = "Zieliński", Gender = "M", HeightCm = 182, WeightKg = 83, BirthDate = new DateTime(1991, 9, 21), UpdatedAt = DateTime.UtcNow },
                new UserProfile { UserId = "10000000-0000-0000-0000-000000000005", FirstName = "Karolina", LastName = "Mazur", Gender = "F", HeightCm = 165, WeightKg = 57, BirthDate = new DateTime(1998, 1, 14), UpdatedAt = DateTime.UtcNow },
                new UserProfile { UserId = "10000000-0000-0000-0000-000000000006", FirstName = "Marek", LastName = "Lewandowski", Gender = "M", HeightCm = 180, WeightKg = 82, BirthDate = new DateTime(1990, 11, 3), UpdatedAt = DateTime.UtcNow }
            );

            var u1 = "10000000-0000-0000-0000-000000000002";
            var u2 = "10000000-0000-0000-0000-000000000003";
            var u3 = "10000000-0000-0000-0000-000000000004";
            var u4 = "10000000-0000-0000-0000-000000000005";
            var u5 = "10000000-0000-0000-0000-000000000006";

            // Stałe daty (HasData nie lubi UtcNow jako dynamicznej wartości)
            var d1 = new DateTime(2025, 12, 20, 12, 0, 0, DateTimeKind.Utc);
            var d2 = new DateTime(2025, 12, 21, 12, 0, 0, DateTimeKind.Utc);
            var d3 = new DateTime(2025, 12, 25, 12, 0, 0, DateTimeKind.Utc);
            var d4 = new DateTime(2025, 12, 26, 12, 0, 0, DateTimeKind.Utc);
            var d5 = new DateTime(2026, 01, 05, 12, 0, 0, DateTimeKind.Utc);
            var d6 = new DateTime(2026, 01, 10, 12, 0, 0, DateTimeKind.Utc);
            var d7 = new DateTime(2026, 01, 11, 12, 0, 0, DateTimeKind.Utc);

            modelBuilder.Entity<FriendRelation>().HasData(
                // u1 <-> u2 (Accepted) инициатор u1
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000001"),
                    UserId = u1,
                    OtherUserId = u2,
                    Status = FriendRelationStatus.Accepted,
                    InitiatorUserId = u1,
                    CreatedAt = d1,
                    UpdatedAt = d2
                },
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000002"),
                    UserId = u2,
                    OtherUserId = u1,
                    Status = FriendRelationStatus.Accepted,
                    InitiatorUserId = u1,
                    CreatedAt = d1,
                    UpdatedAt = d2
                },

                // u1 <-> u3 (Accepted) инициатор u3
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000003"),
                    UserId = u1,
                    OtherUserId = u3,
                    Status = FriendRelationStatus.Accepted,
                    InitiatorUserId = u3,
                    CreatedAt = d3,
                    UpdatedAt = d4
                },
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000004"),
                    UserId = u3,
                    OtherUserId = u1,
                    Status = FriendRelationStatus.Accepted,
                    InitiatorUserId = u3,
                    CreatedAt = d3,
                    UpdatedAt = d4
                },

                // u2 -> u4 (Pending) (2 rekordy Pending, Initiator = u2)
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000005"),
                    UserId = u2,
                    OtherUserId = u4,
                    Status = FriendRelationStatus.Pending,
                    InitiatorUserId = u2,
                    CreatedAt = d6,
                    UpdatedAt = null
                },
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000006"),
                    UserId = u4,
                    OtherUserId = u2,
                    Status = FriendRelationStatus.Pending,
                    InitiatorUserId = u2,
                    CreatedAt = d6,
                    UpdatedAt = null
                },

                // u5 -> u1 (Pending) (2 rekordy Pending, Initiator = u5)
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000007"),
                    UserId = u5,
                    OtherUserId = u1,
                    Status = FriendRelationStatus.Pending,
                    InitiatorUserId = u5,
                    CreatedAt = d7,
                    UpdatedAt = null
                },
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000008"),
                    UserId = u1,
                    OtherUserId = u5,
                    Status = FriendRelationStatus.Pending,
                    InitiatorUserId = u5,
                    CreatedAt = d7,
                    UpdatedAt = null
                },

                // u3 blocks u4 (zostaje tylko rekord u3->u4)
                new FriendRelation
                {
                    Id = Guid.Parse("90000000-0000-0000-0000-000000000009"),
                    UserId = u3,
                    OtherUserId = u4,
                    Status = FriendRelationStatus.Blocked,
                    InitiatorUserId = u3,
                    CreatedAt = d5,
                    UpdatedAt = null
                }
            );


            modelBuilder.Entity<Activity>().HasData(
    // ===== Jan Kowalski (u1) =====
    new Activity
    {
        ID = Guid.Parse("a1000000-0000-0000-0000-000000000001"),
        Name = "Poranny bieg",
        Description = "Lekki bieg przed pracą",
        LengthInKm = 5.2m,
        AuthorId = u1,
        CategoryId = Guid.Parse("11111111-1111-1111-1111-111111111111"), // Bieg
        CreatedAt = d1
    },
    new Activity
    {
        ID = Guid.Parse("a1000000-0000-0000-0000-000000000002"),
        Name = "Trening rowerowy",
        Description = "Rower – interwały",
        LengthInKm = 22.4m,
        AuthorId = u1,
        CategoryId = Guid.Parse("22222222-2222-2222-2222-222222222222"), // Rower
        CreatedAt = d2
    },

    // ===== Anna Nowak (u2) =====
    new Activity
    {
        ID = Guid.Parse("a2000000-0000-0000-0000-000000000001"),
        Name = "Spacer z psem",
        Description = "Spokojny spacer po parku",
        LengthInKm = 3.1m,
        AuthorId = u2,
        CategoryId = Guid.Parse("33333333-3333-3333-3333-333333333333"), // Spacer
        CreatedAt = d3
    },
    new Activity
    {
        ID = Guid.Parse("a2000000-0000-0000-0000-000000000002"),
        Name = "Bieg wieczorny",
        Description = "Tempo progowe",
        LengthInKm = 6.8m,
        AuthorId = u2,
        CategoryId = Guid.Parse("11111111-1111-1111-1111-111111111111"), // Bieg
        CreatedAt = d4
    },

    // ===== Piotr Zieliński (u3) =====
    new Activity
    {
        ID = Guid.Parse("a3000000-0000-0000-0000-000000000001"),
        Name = "Hiking w górach",
        Description = "Tatry – Dolina Kościeliska",
        LengthInKm = 12.5m,
        AuthorId = u3,
        CategoryId = Guid.Parse("44444444-4444-4444-4444-444444444444"), // Hiking
        CreatedAt = d5
    },

    // ===== Karolina Mazur (u4) =====
    new Activity
    {
        ID = Guid.Parse("a4000000-0000-0000-0000-000000000001"),
        Name = "Trening siłowy – FBW",
        Description = "Siłownia – całe ciało",
        LengthInKm = 0m,
        AuthorId = u4,
        CategoryId = Guid.Parse("55555555-5555-5555-5555-555555555555"), // Trening siłowy
        CreatedAt = d6
    },

    // ===== Marek Lewandowski (u5) =====
    new Activity
    {
        ID = Guid.Parse("a5000000-0000-0000-0000-000000000001"),
        Name = "Długi bieg",
        Description = "Bieg tlenowy",
        LengthInKm = 14.3m,
        AuthorId = u5,
        CategoryId = Guid.Parse("11111111-1111-1111-1111-111111111111"), // Bieg
        CreatedAt = d7
    },
    new Activity
    {
        ID = Guid.Parse("a5000000-0000-0000-0000-000000000002"),
        Name = "Rower szosowy",
        Description = "Trasa wiejska",
        LengthInKm = 35.0m,
        AuthorId = u5,
        CategoryId = Guid.Parse("22222222-2222-2222-2222-222222222222"), // Rower
        CreatedAt = d6
    }
    );
        }


    }
}
