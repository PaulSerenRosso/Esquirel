using GameStates;
using UnityEngine;

public partial class UIManager
{
    [SerializeField] private ChampionHUD championOverlay;
    
    public void InitChampionHUD()
    {
        var champion = GameStateMachine.Instance.GetPlayerChampion();
        championOverlay.InitHUD(champion, playerInterface);
    }
}