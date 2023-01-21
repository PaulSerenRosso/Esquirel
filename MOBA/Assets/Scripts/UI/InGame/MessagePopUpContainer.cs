using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class MessagePopUpContainer : MonoBehaviour {
    [SerializeField] private Animator animator = null;
    [SerializeField] private TextMeshProUGUI messageText = null;
    [SerializeField] private Image messageBackground = null;
    [SerializeField] private Image messageOutline = null;

    private static readonly Color redBackgroundCol = new Color(238f / 255f, 73f / 255f, 73f / 255f);
    private static readonly Color redOutlineCol = new Color(140f / 255f, 39f / 255f, 39f / 255f);
    private static readonly Color blueBackgroundCol = new Color(73f / 255f, 144f / 255f, 238f / 255f);
    private static readonly Color blueOutlineCol = new Color(39f / 255f, 75f / 255f, 140f / 255f);


    /// <summary>
    /// Show the message
    /// </summary>
    /// <param name="message"></param>
    /// <param name="messageDuration"></param>
    /// <param name="isPositivePopUp"></param>
    public void ShowMessagePopUp(string message, bool isPositivePopUp) {
        messageBackground.color = isPositivePopUp ? blueBackgroundCol : redBackgroundCol;
        messageOutline.color = isPositivePopUp ? blueOutlineCol : redOutlineCol;
        messageText.text = message;
        
        animator.SetTrigger("Show");
    }
}
