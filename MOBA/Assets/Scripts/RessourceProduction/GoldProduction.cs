using System.Collections;
using System.Collections.Generic;
using CapturePoint;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
public class GoldProduction : CapturePointTickProduction<float, GoldProductionSO>
{
    private UIManager uiManager;
    protected override void OnStart()
    {
        allCapturesPoint = CapturePointCollectionManager.instance.GoldCapturePoints;
        base.OnStart();
        uiManager = UIManager.Instance;
        uiManager.UpdateGoldText(Ressource);
    }

    public override void IncreaseRessource(float amount)
    {
        Ressource += amount;
        if (so.ressourceMax < Ressource)
            Ressource = so.ressourceMax;
    }

    public override void DecreaseRessource(float amount)
    {
        Ressource -= amount;
        if (so.ressourceMin > ressource)
            Ressource = 0;
    }

    public override void UpdateFeedback()
    {
        if(uiManager != null)
        uiManager.UpdateGoldText(ressource);
    }
}
}
