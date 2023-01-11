using System.Collections;
using System.Collections.Generic;
using System.Linq;
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
        private int currentStepIndex;
        public static VictoryProduction firstTeamVictoryProduction;
        public static VictoryProduction secondTeamVictoryProduction;
        protected override void OnStart()
        {
            allCapturesPoint = CapturePointCollectionManager.instance.VictoryCapturePoints;
            base.OnStart();
            uiManager = UIManager.Instance;
            uiManager.UpdateSlider(Ressource, so.ressourceMax, team);
            currentStepIndex = 0;
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    firstTeamVictoryProduction = this;
                    break;
                }
                case Enums.Team.Team2:
                {
                    secondTeamVictoryProduction = this;
                    break;
                }
            }
        }

        public override void UpdateFeedback(float value)
        {
            if (uiManager != null)
                uiManager.UpdateSlider(value, so.ressourceMax, team);
        }

        public override void IncreaseRessource(float amount)
        {
            Ressource += amount;
            if (Ressource > so.ressourceMax)
            {
                GameStateMachine.Instance.SendWinner(team);
            }

            if (Ressource >= so.VictorySteps[currentStepIndex])
            {
                // give point
                
                currentStepIndex++;
            }
        }

        public override void DecreaseRessource(float amount)
        {
            throw new System.NotImplementedException();
        }
    }
}