using UnityEngine;

public class MessagePopUpManager : MonoBehaviour
{
    public static MessagePopUpManager Instance;

    private void Awake()
    {
        if (Instance == null) Instance = this;
    }

    [SerializeField] private GameObject messagePopUpGam = null;
    [SerializeField] private Transform messageParent = null;

    #region Preset

    
    public void SendAllyWantSurrender() =>
        CreateMessagePopUp("Your ally wants to surrender ! Press O for surrender.", false);
    public void SendAllyCancelSurrender() =>
        CreateMessagePopUp("Your ally doesn't want surrender anymore !.", false);
    
    public void SendYouWantSurrender() =>
        CreateMessagePopUp("You want to surrender ! Press P for cancel.", false);
    public void SendYouCancelSurrender() =>
        CreateMessagePopUp("You doesn't want surrender anymore !.", false);
    public void SendEnemyReachStep() =>
        CreateMessagePopUp("The enemies reached a step ! They won an aura point !", false);

    public void SendAllyReachStep() => CreateMessagePopUp("You reached a step ! You won an aura point !", true);

    public void SendPlayerDie(int bountyAmount) =>
        CreateMessagePopUp($"You died. The enemies stole {bountyAmount} golds from you.", false);

    public void SendAllyPlayerDie(int bountyAmount) =>
        CreateMessagePopUp($"Your ally died. The enemies stole {bountyAmount} golds from you .", false);

    public void SendEnemyPlayerDie(int bountyAmount) =>
        CreateMessagePopUp($"An enemy died. You stole {bountyAmount} golds from enemies.", true);

    public void SendEnemyIncreaseStreak(int victoryPointAmount, int goldCost) => CreateMessagePopUp(
        $"The enemies make a streak ! They won victory points against {goldCost} golds.",
        false);

    public void SendAllyIncreaseStreak(int victoryPointAmount, int goldCost) => CreateMessagePopUp(
        $"You make a streak ! You won victory points against {goldCost} golds.",
        true );

    public void SendAllyBreakStreak() => CreateMessagePopUp("Your streak broke !", false );

    public void SendEnemyBreakStreak() => CreateMessagePopUp("The enemies' streak broke !", true);
    

    #endregion


    // un allié est mort 
    // un ennemy est tué 
    // ou loss a streak
    // on win a streak; 
    // ennemy lose streak
    // ennemy win streak
    // élminiation totale de léquipe advser
    // élimination totale de l'équipe allié

    /// <summary>
    /// Show a PopUpMessage
    /// </summary>
    /// <param name="message"></param>
    /// <param name="isPositive"></param>
    /// <param name="messageDuration"></param>
    public void CreateMessagePopUp(string message, bool isPositive)
    {
      
        GameObject popUp = Instantiate(messagePopUpGam, messageParent);
        popUp.GetComponent<MessagePopUpContainer>().ShowMessagePopUp(message, isPositive);
    }
}