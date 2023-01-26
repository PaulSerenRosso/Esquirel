using System;
using GameStates;
using Photon.Pun;
using TMPro;
using UnityEngine;

public class DebugManager : MonoBehaviour
{
    [SerializeField] private GameObject debguButtons = null;
    [SerializeField] private GameObject debguPing = null;
    [SerializeField] private GameObject debguMaster = null;
    [SerializeField] private GameObject debguTick = null;
    [SerializeField] private TextMeshProUGUI clientDataText;

    private void Start()
    {
        var id = PhotonNetwork.LocalPlayer.ActorNumber;
        clientDataText.text = $"Client {id} / {GameStateMachine.Instance.GetPlayerTeam()}";
    }

    public void OnStartInGameState()
    {
        GameStateMachine.Instance.SwitchState(2);
    }

    public void OnTeamWins(int index)
    {
        if (PhotonNetwork.IsMasterClient)
        {

            if (index == 0)
                GameStateMachine.Instance.SendWinner(Enums.Team.Team1);
            else
                GameStateMachine.Instance.SendWinner(Enums.Team.Team2);

        }
    }

    public void OnDieButtonClick()
        {
            GameStateMachine.Instance.GetPlayerChampion().RequestDie();
        }

        public void OnDamageButtonClick()
        {
            GameStateMachine.Instance.GetPlayerChampion().DecreaseCurrentHpRPC(1);
        }

        public void StopGame()
        {
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.F3))
            {
                debguButtons.SetActive(!debguButtons.activeSelf);
                debguPing.SetActive(!debguPing.activeSelf);
                debguMaster.SetActive(!debguMaster.activeSelf);
                debguTick.SetActive(!debguTick.activeSelf);
            }
        }
    }