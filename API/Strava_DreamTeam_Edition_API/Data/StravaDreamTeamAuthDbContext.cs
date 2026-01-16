using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Strava_DreamTeam_Edition_API.Data
{
    public class StravaDreamTeamAuthDbContext : IdentityDbContext<IdentityUser, IdentityRole, string>
    {
        public StravaDreamTeamAuthDbContext(DbContextOptions<StravaDreamTeamAuthDbContext> options)
            : base(options) { }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);

            // Roles
            var adminRoleId = "c1a1f400-1d2b-4f5a-8b66-aaaaaaaaaaaa";
            var userRoleId = "d2b2f511-2e3c-5g6b-9c77-bbbbbbbbbbbb";

            builder.Entity<IdentityRole>().HasData(
                new IdentityRole { Id = adminRoleId, Name = "Admin", NormalizedName = "ADMIN" },
                new IdentityRole { Id = userRoleId, Name = "User", NormalizedName = "USER" }
            );

            // IDs
            var adminId = "10000000-0000-0000-0000-000000000001";
            var u1 = "10000000-0000-0000-0000-000000000002";
            var u2 = "10000000-0000-0000-0000-000000000003";
            var u3 = "10000000-0000-0000-0000-000000000004";
            var u4 = "10000000-0000-0000-0000-000000000005";
            var u5 = "10000000-0000-0000-0000-000000000006";

            var hasher = new PasswordHasher<IdentityUser>();

            var admin = new IdentityUser
            {
                Id = adminId,
                UserName = "admin",
                NormalizedUserName = "ADMIN",
                Email = "admin@strava.local",
                NormalizedEmail = "ADMIN@STRAVA.LOCAL",
                EmailConfirmed = true,
                PasswordHash = hasher.HashPassword(null!, "Admin@123")
            };

            var users = new[]
            {
        new IdentityUser
        {
            Id = u1, UserName = "j.kowalski", NormalizedUserName = "J.KOWALSKI",
            Email = "jan.kowalski@strava.local", NormalizedEmail = "JAN.KOWALSKI@STRAVA.LOCAL",
            EmailConfirmed = true, PasswordHash = hasher.HashPassword(null!, "User@123")
        },
        new IdentityUser
        {
            Id = u2, UserName = "a.nowak", NormalizedUserName = "A.NOWAK",
            Email = "anna.nowak@strava.local", NormalizedEmail = "ANNA.NOWAK@STRAVA.LOCAL",
            EmailConfirmed = true, PasswordHash = hasher.HashPassword(null!, "User@123")
        },
        new IdentityUser
        {
            Id = u3, UserName = "p.zielinski", NormalizedUserName = "P.ZIELINSKI",
            Email = "piotr.zielinski@strava.local", NormalizedEmail = "PIOTR.ZIELINSKI@STRAVA.LOCAL",
            EmailConfirmed = true, PasswordHash = hasher.HashPassword(null!, "User@123")
        },
        new IdentityUser
        {
            Id = u4, UserName = "k.mazur", NormalizedUserName = "K.MAZUR",
            Email = "karolina.mazur@strava.local", NormalizedEmail = "KAROLINA.MAZUR@STRAVA.LOCAL",
            EmailConfirmed = true, PasswordHash = hasher.HashPassword(null!, "User@123")
        },
        new IdentityUser
        {
            Id = u5, UserName = "m.lewandowski", NormalizedUserName = "M.LEWANDOWSKI",
            Email = "marek.lewandowski@strava.local", NormalizedEmail = "MAREK.LEWANDOWSKI@STRAVA.LOCAL",
            EmailConfirmed = true, PasswordHash = hasher.HashPassword(null!, "User@123")
        }
    };

            builder.Entity<IdentityUser>().HasData(admin);
            builder.Entity<IdentityUser>().HasData(users);

            builder.Entity<IdentityUserRole<string>>().HasData(
                new IdentityUserRole<string> { RoleId = adminRoleId, UserId = adminId },
                new IdentityUserRole<string> { RoleId = userRoleId, UserId = u1 },
                new IdentityUserRole<string> { RoleId = userRoleId, UserId = u2 },
                new IdentityUserRole<string> { RoleId = userRoleId, UserId = u3 },
                new IdentityUserRole<string> { RoleId = userRoleId, UserId = u4 },
                new IdentityUserRole<string> { RoleId = userRoleId, UserId = u5 }
            );
        }
    }
}
