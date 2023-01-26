using Entities.Champion;
using GameStates;
using Photon.Pun;
using UnityEngine;

public partial class UIManager
{
    [SerializeField] private ChampionHUD championOverlay;

    public void InitChampionHUD()
    {
        var champion = GameStateMachine.Instance.GetPlayerChampion();
        championOverlay.InitHUD(champion, playerInterface);
    }


    public void CancelRecacstCooldown(Champion champion)
    {
        if (champion.photonView.IsMine)
        {
            if (PhotonNetwork.IsMasterClient)
                GameStateMachine.Instance.OnTick -= UpdateRecacstCooldown;
            else
                GameStateMachine.Instance.OnTickFeedback -= UpdateRecacstCooldownFeedBack;
            playerInterface.CancelRecacstCooldown();
        }
    }

    private double recastTimer;
    private float recastCooldown;
    public void LaunchRecastCooldown(Champion champion, float cooldown)
    {
        recastCooldown = cooldown;
        recastTimer = 0; 
        if (champion.photonView.IsMine)
        { 
            if(PhotonNetwork.IsMasterClient)
                GameStateMachine.Instance.OnTick+= UpdateRecacstCooldown;
            else
                GameStateMachine.Instance.OnTickFeedback += UpdateRecacstCooldownFeedBack;
        }
    }
    void UpdateRecacstCooldownFeedBack(double timerDiff)
    {   
        Debug.Log("bonsoir àt ous");
        recastTimer += timerDiff;
        playerInterface.ChangeRecastCooldown((float) recastTimer,recastCooldown);
    }
        
    void UpdateRecacstCooldown()
    {   
        Debug.Log("bonsoir àt ous");
        recastTimer += 1/GameStateMachine.Instance.tickRate;
        playerInterface.ChangeRecastCooldown((float) recastTimer,recastCooldown);
    }
        
        
}