using System.ComponentModel.DataAnnotations;

namespace Strava_DreamTeam_Edition_API.Models.DTO
{
    public class RegisterRequestDto
    {
        [Required]
        public string Username { get; set; }

        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        [Required]
        [DataType(DataType.EmailAddress)]
        public string Email { get; set; }


        public string[] Roles { get; set; }
    }
}
