using System.Collections;
using System.Collections.Generic;
using System.Linq;
using CapturePoint;
using GameStates;
using Photon.Pun;
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

        public event GlobalDelegates.NoParameterDelegate reachStepEvent;
        protected override void OnStart()
        {
            allCapturesPoint = CapturePointCollectionManager.instance.VictoryCapturePoints;
            base.OnStart();
            uiManager = UIManager.Instance;
            uiManager.UpdateSlider(Ressource, so.ressourceMax, team);
            RequestSetCurrentStepIndex(0);
            var playerTeam = GameStateMachine.Instance.GetPlayerTeam();
            if (playerTeam == team)
            {
                reachStepEvent += MessagePopUpManager.Instance.SendAllyReachStep;
            }
            else   reachStepEvent += MessagePopUpManager.Instance.SendEnemyReachStep;
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

            if (currentStepIndex != so.victorySteps.Count)
            {
                if (Ressource >= so.victorySteps[currentStepIndex].triggerValue)
                {
                    foreach (var player in GameStateMachine.Instance.playersReadyDict)
                    {
                        var champion = player.Value.champion;
                        if (champion.team == team)
                        {
                            champion.auraProduction.IncreaseRessource(so.victorySteps[currentStepIndex].auraAmount);
                            
                        }
                    }
                  RequestSetCurrentStepIndex(currentStepIndex+1);
                }
            }
        }

        void RequestSetCurrentStepIndex(int stepIndex) =>
            photonView.RPC("SyncSetCurrentStepIndexRPC", RpcTarget.All, stepIndex);
        [PunRPC]
        void SyncSetCurrentStepIndexRPC(int stepIndex)
        {
            if(stepIndex > currentStepIndex)
                reachStepEvent?.Invoke();
            currentStepIndex = stepIndex;
        }
        
        public override void DecreaseRessource(float amount)
        {
            throw new System.NotImplementedException();
        }


    }
}