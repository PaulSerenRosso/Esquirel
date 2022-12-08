using UnityEngine;

[CreateAssetMenu(menuName = "Custom Editor SO/Discord Bot")]
public class DiscordBotSO : ScriptableObject {
    [SerializeField] private string botUsername = "";
    public string BotUsername => botUsername;
    [SerializeField] private string botAvatarDirectory = "";
    public string BotAvatarDirectory => botAvatarDirectory;
    [Space]
    [SerializeField] private string webhookLink = "";
    public string WebhookLink => webhookLink;
    
    /// <summary>
    /// Allowed the user to test if the Webhook works
    /// </summary>
    public void TestWebhook() => DiscordHelper.SendDiscordMessage("This is a test from the unity webhook", webhookLink, botUsername, botAvatarDirectory);
}
