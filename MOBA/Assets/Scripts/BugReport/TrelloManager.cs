using System;
using System.Collections;
using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;

namespace TrelloBugReport {
    public class TrelloManager : MonoBehaviour {
        [Header("Trello information")] 
        [SerializeField] private TrelloLinkSO trello = null;
        [SerializeField] private DiscordBotSO messageBot = null;

        [Header("Trello information")]
        [SerializeField] private GameObject bugReportWindow = null;
        [SerializeField] private TMP_InputField bugNameIF = null;
        [SerializeField] private TMP_Dropdown bugTypeDropdown = null;
        [SerializeField] private TMP_InputField descriptionIF = null;
        [SerializeField] private Toggle addScreenshotToggle = null;
        private byte[] screenshot;

        private void Start() => bugReportWindow.SetActive(false);
        private void Update() {
            if (Input.GetKeyDown(KeyCode.F2)) {
                if(!bugReportWindow.activeSelf) StartOpening();
                else CloseBugReportWindow();
            }
        }

        #region OpenBugReportWindow
        /// <summary>
        /// Start to open the report window
        /// </summary>
        public void StartOpening() => StartCoroutine(UploadImage());
        /// <summary>
        /// Open the window and reset all value after taking the screenshot
        /// </summary>
        private void OpenBugReportWindow() {
            bugReportWindow.SetActive(true);
            bugNameIF.text = "";
            bugTypeDropdown.options = trello.Labels.Select(label => new TMP_Dropdown.OptionData(label.labelName)).ToList();
            descriptionIF.text = "";
            addScreenshotToggle.isOn = true;
        }
        /// <summary>
        /// Get a screenshot of the current camera
        /// </summary>
        /// <returns></returns>
        private IEnumerator UploadImage() {
            yield return new WaitForEndOfFrame();
            int width = Screen.width;
            int height = Screen.height;
            Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, false);
            tex.ReadPixels(new Rect(0,0,width,height), 0 ,0);
            tex.Apply();
            screenshot = tex.EncodeToPNG();
            Destroy(tex);
            
            yield return new WaitForEndOfFrame();
            OpenBugReportWindow();
        }
        #endregion OpenBugReportWindow
        
        #region PostCard
        /// <summary>
        /// Create and Post a card
        /// </summary>
        /// <param name="card"></param>
        public void CreateAndPostCard() {
            TrelloCard card = new TrelloCard(bugNameIF.text, descriptionIF.text, bugTypeDropdown.options[bugTypeDropdown.value].text.ToString(), screenshot);

            WWWForm form = new WWWForm();
            form.AddField("name", card.name);
            form.AddField("desc", card.description);
            form.AddField("idLabels", trello.GetLabelBasedOnName(card.labelName));
            if(addScreenshotToggle.isOn) form.AddBinaryData("fileSource", screenshot, $"BugReport_Screenshot_{DateTime.UtcNow.ToString()}.png");

            UnityWebRequest uwr = form.PostWebRequest(trello.PostCardLink);
            bugReportWindow.SetActive(false);
            
            while (!uwr.isDone) { }
            DiscordHelper.SendDiscordMessage($"> **BUG : {card.name.ToUpper()}**\n> **Type :** {card.labelName}\n> **Description :** {card.description}\n> **URL :** {JsonUtility.FromJson<CardJSON>(uwr.downloadHandler.text).shortUrl}", messageBot);
        }
        #endregion PostCard

        /// <summary>
        /// Close the bug report window
        /// </summary>
        public void CloseBugReportWindow() => bugReportWindow.SetActive(false);
    }

    public class CardJSON {
        public string shortUrl;
    }
}