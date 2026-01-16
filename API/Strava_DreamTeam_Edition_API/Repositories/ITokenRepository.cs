using Microsoft.AspNetCore.Identity;

namespace Strava_DreamTeam_Edition_API.Repositories
{
    public interface ITokenRepository
    {
        string CreateJWTToken(IdentityUser user, List<string> roles);
    }
}
