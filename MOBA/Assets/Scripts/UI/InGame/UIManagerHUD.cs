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
            GameStateMachine.Instance.OnTickFeedback -= UpdateRecacstCooldown;
        playerInterface.CancelRecacstCooldown();
        }
    }

    private double recastTimer;
    private float recastCooldown;
    public void LaunchRecastCooldown(Champion champion, float cooldown)
    {
        recastTimer = (double) cooldown;
        if (champion.photonView.IsMine)
        {
            GameStateMachine.Instance.OnTickFeedback += UpdateRecacstCooldown;
        }
    }
        void UpdateRecacstCooldown(double timerDiff)
        {   
            recastTimer -= timerDiff;
            playerInterface.ChangeRecastCooldown((float) recastTimer,recastCooldown);
        }
        
        
}