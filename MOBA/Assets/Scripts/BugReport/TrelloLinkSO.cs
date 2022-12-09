using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

namespace TrelloBugReport {
    [CreateAssetMenu(menuName = "Tools/Trello Bug Report")]
    public class TrelloLinkSO : ScriptableObject {
        #region Variables
        private string token = "075ff50f8f88a61a24101ec312f6932db5e50989e7f64bf5fe662989bb61201e";
        private string keyAPI = "0bebe3cb97a6d3b1fc18f175d707b496";
        
        [Header("Trello API Information")]
        [SerializeField] private string boardID = "63920d55e968f0024be27ad0";
        [SerializeField] private string listID = "63920deb0c7949010f3ddfa9";
        public string ListID => listID;
        [Space]
        [SerializeField] private List<TrelloLabel> labels;
        public List<TrelloLabel> Labels => labels;

        private string postCardLink => $"https://api.trello.com/1/cards?idList={listID}&key={keyAPI}&token={token}";
        public string PostCardLink => postCardLink;
        #endregion
        
        /// <summary>
        /// Get the label ID based on the name of the label
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        public string GetLabelBasedOnName(string name) {
            foreach (TrelloLabel label in labels) {
                if (label.labelName == name) return label.labelID;
            }

            return "";
        }
    }
    
    /// <summary>
    /// Class which allow to create a new TrelloCard
    /// </summary>
    public class TrelloCard {
        public string name;
        public string description;
        public string labelName;
        public byte[] screenshot;

        public TrelloCard(string name, string description, string labelName, byte[] screenshot) {
            this.name = name;
            this.description = description;
            this.labelName = labelName;
            this.screenshot = screenshot;
        }
    }

    [System.Serializable]
    public class TrelloLabel {
        public string labelName;
        public string labelID;
    }
}
