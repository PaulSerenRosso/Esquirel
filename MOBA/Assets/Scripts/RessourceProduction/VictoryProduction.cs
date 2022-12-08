using System.Collections;
using System.Collections.Generic;
using GameStates;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
public class VictoryProduction : CapturePointTickProduction<float>
{
    // Start is called before the first frame update
    public override void UpdateFeedback()
    {
       
    }
    public override void IncreaseRessource(float amount)
    {
        ressource += amount;
        if (ressource > ressourceMax)
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
