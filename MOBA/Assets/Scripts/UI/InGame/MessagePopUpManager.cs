using UnityEngine;

public class MessagePopUpManager : MonoBehaviour {
    public static MessagePopUpManager Instance;
    private void Awake() {
        if (Instance == null) Instance = this;
    }

    [SerializeField] private GameObject messagePopUpGam = null;
    [SerializeField] private Transform messageParent = null;

    private void Update() {
        if (Input.GetKeyDown(KeyCode.L)) {
            if (Random.Range(0, 2) == 1) SendAuraMessage();
            else SendCaptureMessage();
        }
    }

    #region Preset
    public void SendAuraMessage() => CreateMessagePopUp("You just gain an \"Aura\" point", true);
    public void SendCaptureMessage() => CreateMessagePopUp("An enemy is trying to capture the generator", false);
    #endregion

    /// <summary>
    /// Show a PopUpMessage
    /// </summary>
    /// <param name="message"></param>
    /// <param name="isPositive"></param>
    /// <param name="messageDuration"></param>
    public void CreateMessagePopUp(string message, bool isPositive) {
        GameObject popUp = Instantiate(messagePopUpGam, messageParent);
        popUp.GetComponent<MessagePopUpContainer>().ShowMessagePopUp(message, isPositive);
    }
}
