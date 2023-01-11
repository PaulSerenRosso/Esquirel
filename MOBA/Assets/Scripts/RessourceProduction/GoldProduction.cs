using System.Collections;
using System.Collections.Generic;
using System.Linq;
using CapturePoint;
using Entities;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using RessourceProduction;
using UnityEngine;

namespace RessourceProduction
{
    public class GoldProduction : CapturePointTickProduction<float, GoldProductionSO>
    {
        private int currentStreakLevel;
        private UIManager uiManager;
        public static GoldProduction firstTeamGoldProduction;
        public static GoldProduction secondGoldProduction;
        
        protected override void OnStart()
        {
            allCapturesPoint = CapturePointCollectionManager.instance.GoldCapturePoints;
            base.OnStart();
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    firstTeamGoldProduction = this;
                    break;
                }
                case Enums.Team.Team2:
                {
                    secondGoldProduction = this;
                    break;
                }
            }
            for (int i = 0; i < allCapturesPoint.Length; i++)
            {
                switch (team)
                {
                    case Enums.Team.Team1:
                    {
                        allCapturesPoint[i].firstTeamState.exitStateEvent += TryBreakCurrentStreak;
                        break;
                    }
                    case Enums.Team.Team2:
                    {
                        allCapturesPoint[i].secondTeamState.exitStateEvent += TryBreakCurrentStreak;
                        break;
                    }
                }
            }
            uiManager = UIManager.Instance;
            uiManager.UpdateGoldText(Ressource);
            currentStreakLevel = 0;
        }

        public void LinkBounty(Champion enemyChampion)
        {
            enemyChampion.OnDie += IncreaseRessourceWithBounty;
        }

        public void IncreaseRessourceWithBounty()
        {
            switch (team)
            {
                case Enums.Team.Team1 :
                {
                    float bounty = secondGoldProduction.ressource *
                                             secondGoldProduction.so.bountyPercentage;
                    secondGoldProduction.DecreaseRessource(bounty);
                    IncreaseRessource(bounty);
                    break;
                }
                case Enums.Team.Team2 :
                {
                    float bounty = firstTeamGoldProduction.ressource *
                                   firstTeamGoldProduction.so.bountyPercentage;
                    firstTeamGoldProduction.DecreaseRessource(bounty);
                    IncreaseRessource(bounty);
                    break;
                }
            }
        }

        public void TryBreakCurrentStreak()
        {
            if(currentStreakLevel == 0) return;
            if(!allCapturesPoint.All(point => point.team == team))
            {
                currentStreakLevel = 0;
            }
        }

        public override void IncreaseRessource(float amount)
        {
            Ressource += amount;
            if (so.ressourceMax < Ressource)
                Ressource = so.ressourceMax;
            if (allCapturesPoint.All(point => point.team == team))
            {
                var soStreak = so.streaks[currentStreakLevel];
                if (ressource >= soStreak)
                {
                    DecreaseRessource(soStreak);
                    switch (team)
                    {
                        case Enums.Team.Team1:
                        {
                            VictoryProduction.firstTeamVictoryProduction.IncreaseRessource(so.victoryAmount);
                            break;
                        }
                        case Enums.Team.Team2:
                        {
                            VictoryProduction.secondTeamVictoryProduction.IncreaseRessource(so.victoryAmount);
                            break;
                        }
                    }
                    // convert
                    if (currentStreakLevel != so.streaks.Count - 1)
                        currentStreakLevel++;
                }
            }
            //  convert en gland automatiquement 
            // streaks
            
            // casser une streak ajouter event restart
        }

        public void RequestDecreaseRessource(float amount)
        {
            photonView.RPC("DecreaseRessource", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public override void DecreaseRessource(float amount)
        {
            Ressource -= amount;
            if (so.ressourceMin > ressource)
                Ressource = 0;
        }

        public override void UpdateFeedback(float value)
        {
            if (uiManager != null && GameStateMachine.Instance.GetPlayerTeam() == team)
                uiManager.UpdateGoldText(value);
        }
    }
}