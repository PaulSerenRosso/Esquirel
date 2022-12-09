using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(DiscordBotSO))]
public class DiscordBotSOEditor : Editor {
    
    /// <summary>
    /// Draw the inspector
    /// </summary>
    public override void OnInspectorGUI() {
        base.OnInspectorGUI();
        if(GUILayout.Button("Test Webhook")) ((DiscordBotSO)target).TestWebhook();
    }
}
