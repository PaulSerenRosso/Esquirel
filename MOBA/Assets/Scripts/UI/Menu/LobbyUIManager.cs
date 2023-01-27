using System;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class LobbyUIManager : MonoBehaviourPun
{
    public static LobbyUIManager Instance;
    private GameStateMachine sm;

    [Header("Connection Part")] [SerializeField]
    private GameObject connectionPart;

    [SerializeField] private GameObject waitingTextObject;
    [SerializeField] private GameObject goTextObject;

    [Header("Selection Part")] [SerializeField]
    private Button readyButton;

    [SerializeField] private TextMeshProUGUI readyButtonText;
    [SerializeField] private Color selectedChampionColor;
    [SerializeField] private Color unselectedChampionColor;
    [SerializeField] private Image firstChampionColorImage;
    [SerializeField] private Image secondChampionColorImage;
    [SerializeField] private Sprite unselectedChampion01 = null;
    [SerializeField] private Sprite unselectedChampion02 = null;
    [SerializeField] private Sprite selectedChampion01 = null;
    [SerializeField] private Sprite selectedChampion02 = null;
    [SerializeField] private Color firstTeamColor;
    [SerializeField] private Color secondTeamColor;
    [SerializeField] private Image buttonTeamImg = null;
    [SerializeField] private TextMeshProUGUI buttonTeamTxt = null;
    [SerializeField] private Sprite blueTeamSprite = null;
    [SerializeField] private Sprite redTeamSprite = null;
    private bool isFirstTeam = true;

    [Header("Network")] [SerializeField] private ClientInformation[] allClientsInformation;

    [Header("Data")] private byte currentChampion;
    private Enums.Team currentTeam;
    private bool isReady;

    [Header("Debug")] public Button debugButton;

    [Serializable]
    private struct ClientInformation
    {
        public GameObject obj;
        public TextMeshProUGUI clientChampionNameText;
        public Image clientTeamColorfulImage;
        public Image clientReadyStateImage;
    }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            DestroyImmediate(gameObject);
            return;
        }

        Instance = this;
    }
    
    public void Initialization()
    {
        sm = GameStateMachine.Instance;

        readyButton.interactable = false;

        firstChampionColorImage.sprite = unselectedChampion01;
        secondChampionColorImage.sprite = unselectedChampion02;

        // Default is no champion selected
        currentChampion = 2;
        currentTeam = Enums.Team.Team1;

        // We sync others' data
        sm.RequestSendDataDictionary();
        
        // We add a player
        sm.RequestAddPlayer();

        // Default is first team
        sm.RequestSetTeam((byte)currentTeam);

        // Send information to other players
        RequestShow();

        // Get information from other players
        RequestGetConnectedPlayersInformation();
    }

    public void OnToggleReadyClick()
    {
        // We switch state
        isReady = !isReady;

        // We change GUI
        connectionPart.SetActive(isReady);
        readyButtonText.text = isReady ? "Cancel" : "Ready ?";

        // We send request to Master
        sm.SendSetToggleReady(isReady);
        
        // Send information to other players
        RequestShow();
    }

    public void OnChampionClick(int index)
    {
        if (isReady) return;

        currentChampion = (byte)index;

        switch (index)
        {
            // We change GUI
            case 0:
                firstChampionColorImage.sprite = selectedChampion01;
                secondChampionColorImage.sprite = unselectedChampion02;
                break;
            case 1:
                firstChampionColorImage.sprite = unselectedChampion01;
                secondChampionColorImage.sprite = selectedChampion02;
                break;
            default:
                Debug.LogError("Index is not valid. Must be 0 or 1.");
                return;
        }

        readyButton.interactable = true;

        // We send request to Master
        sm.RequestSetChampion(currentChampion);

        // Send information to other players
        RequestShow();
    }

    public void OnTeamClick()
    {
        if (isReady) return;

        // We switch team
        isFirstTeam = !isFirstTeam;
        var index = isFirstTeam ? 1 : 2;

        currentTeam = (Enums.Team)index;

        // We change GUI
        buttonTeamImg.sprite = isFirstTeam ? blueTeamSprite : redTeamSprite;
        buttonTeamTxt.text = isFirstTeam ? "Blue team" : "Red team";

        // We send request to Master
        sm.RequestSetTeam((byte)currentTeam);

        // Send information to other players
        RequestShow();
    }

    public void SendStartGame()
    {
        photonView.RPC("SyncStartGameRPC", RpcTarget.All);
    }
    
    [PunRPC]
    private void SyncStartGameRPC()
    {
        debugButton.interactable = false;
        
        waitingTextObject.SetActive(false);
        goTextObject.SetActive(true);
    }

    private void RequestShow()
    {
        photonView.RPC("ShowRPC", RpcTarget.MasterClient, PhotonNetwork.LocalPlayer.ActorNumber, (byte)currentTeam,
            currentChampion, isReady);
    }

    [PunRPC]
    private void ShowRPC(int photonID, byte team, byte champion, bool ready)
    {
        photonView.RPC("SyncShowRPC", RpcTarget.All, photonID, team, champion, ready);
    }

    [PunRPC]
    private void SyncShowRPC(int photonID, byte team, byte champion, bool ready)
    {
        if (photonID > allClientsInformation.Length)
        {
            Debug.LogError("ID is not valid");
        }
        
        // We set GUI
        allClientsInformation[photonID - 1].obj.SetActive(true);
        allClientsInformation[photonID - 1].clientChampionNameText.text = champion switch
        {
            0 => "Sergio",
            1 => "Poumf",
            2 => "Waiting...",
            _ => "No valid!"
        };

        allClientsInformation[photonID - 1].clientTeamColorfulImage.color = team switch
        {
            0 => unselectedChampionColor,
            1 => firstTeamColor,
            2 => secondTeamColor,
            _ => allClientsInformation[photonID].clientTeamColorfulImage.color
        };

        allClientsInformation[photonID - 1].clientReadyStateImage.color = ready ? Color.green : Color.red;
    }

    private void RequestGetConnectedPlayersInformation()
    {
        photonView.RPC("GetConnectedPlayersInformationRPC", RpcTarget.MasterClient);
    }

    [PunRPC]
    private void GetConnectedPlayersInformationRPC()
    {
        photonView.RPC("SyncGetConnectedPlayersInformationRPC", RpcTarget.All);
    }

    [PunRPC]
    private void SyncGetConnectedPlayersInformationRPC()
    {
        RequestShow();
    }

    public void OnDebugClick()
    {
        sm.StartCoroutine(sm.StartingGame());
    }
}