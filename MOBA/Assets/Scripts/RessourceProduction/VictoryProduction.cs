using System.Collections;
using System.Collections.Generic;
using CapturePoint;
using GameStates;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
public class VictoryProduction : CapturePointTickProduction<float, VictoryProductionSO>
{
    // Start is called before the first frame update
    private UIManager uiManager;
    protected override void OnStart()
    {
        allCapturesPoint= CapturePointCollectionManager.instance.VictoryCapturePoints;
        base.OnStart();
        uiManager = UIManager.Instance;
        uiManager.UpdateSlider(Ressource,so.ressourceMax, team);
   
    }
    public override void UpdateFeedback()
    {
        if(uiManager != null)
        uiManager.UpdateSlider(Ressource,so.ressourceMax, team);
    }
    public override void IncreaseRessource(float amount)
    {
        Ressource += amount;
        if (Ressource > so.ressourceMax)
        {
            GameStateMachine.Instance.SendWinner(team);
        }
    }

    public override void DecreaseRessource(float amount)
    {
        throw new System.NotImplementedException();
    }
}
}
