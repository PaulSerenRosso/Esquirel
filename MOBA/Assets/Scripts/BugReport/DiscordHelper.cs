using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public static class DiscordHelper {
    private static string defaultBotUsername = "";
    private static string defaultBotAvatar = "";


    /// <summary>
    /// Send a Discord Message
    /// </summary>
    /// <returns></returns>
    public static void SendDiscordMessage(string message, string webhookLink, string botUsername = "", string botAvatar = "") {
        //Get the message parameters
        Dictionary<string, string> parameters = new Dictionary<string, string> {
            {"username", botUsername == "" ? defaultBotUsername : botUsername},
            {"content", message},
            {"avatar_url", botAvatar == "" ? defaultBotAvatar : botAvatar},
        };

        UnityWebRequest discordRequest = UnityWebRequest.Post(webhookLink, parameters);
        discordRequest.SendWebRequest();

        while (!discordRequest.isDone) { }
        Debug.Log($"The Discord message [{message}] has been send");
    }
    
    /// <summary>
    /// Send a Discord Message
    /// </summary>
    /// <returns></returns>
    public static void SendDiscordMessage(string message, DiscordBotSO bot) {
        //Get the message parameters
        Dictionary<string, string> parameters = new Dictionary<string, string> {
            {"username", bot.BotUsername == "" ? defaultBotUsername : bot.BotUsername},
            {"content", message},
            {"avatar_url", bot.BotAvatarDirectory == "" ? defaultBotAvatar : bot.BotAvatarDirectory},
        };

        UnityWebRequest discordRequest = UnityWebRequest.Post(bot.WebhookLink, parameters);
        discordRequest.SendWebRequest();

        while (!discordRequest.isDone) { }
        Debug.Log($"The Discord message [{message}] has been send");
    }
}