using System.Collections;
using GameStates;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class PostGameUIManager : MonoBehaviour
{
    public static PostGameUIManager Instance;

    [SerializeField] private GameObject postGameCanvas;
    [SerializeField] private TextMeshProUGUI winningTeamText;
    [SerializeField] private TextMeshProUGUI resultText;

    [SerializeField] private Button rematchButton;
    
    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            DestroyImmediate(gameObject);
            return;
        }

        Instance = this;
    }

    public void DisplayPostGame(Enums.Team winner, bool isSurrender = false)
    {
        if (isSurrender)
        {
            winningTeamText.text = $"{winner} has won by surrender !";  
        } 
        else
        {
            winningTeamText.text = $"{winner} has won!";
        }
        postGameCanvas.SetActive(true);
        var playerTeam = GameStateMachine.Instance.GetPlayerTeam();
        if (isSurrender)
        {
            resultText.text = playerTeam == winner ? "You won!" : "You surrender!";
        }
        else
        {
            resultText.text = playerTeam == winner ? "You won!" : "You lost!";
        }
        
    }

    public void OnRematchClick()
    {
        Time.timeScale = 1; 
        StartCoroutine(WaitForRematch());



    }

    IEnumerator WaitForRematch()
    {
        yield return new WaitForEndOfFrame();
        Object.Destroy(GameStateMachine.Instance.gameObject);
        PhotonNetwork.LeaveRoom();
        NetworkManager.Instance.OnLeftRoom();
    }
}
