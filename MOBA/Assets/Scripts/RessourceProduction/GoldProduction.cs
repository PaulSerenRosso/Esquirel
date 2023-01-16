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
    public class GoldProduction : CapturePointTickProduction<int, GoldProductionSO>
    {
        private int CurrentStreakLevel
        {
            get
            {
                return currentStreakLevel;
            }

            set
            {
                currentStreakLevel = value;
                UIManager.Instance.UpdateStreak(currentStreakLevel, so.streaks[currentStreakLevel], team);
                
            }
        }
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
            uiManager.UpdateGoldText(Ressource, team);
            CurrentStreakLevel = 0;
        }

        public void LinkBounty(Champion enemyChampion)
        {
            enemyChampion.OnDie += IncreaseRessourceWithBounty;
        }

        public void IncreaseRessourceWithBounty()
        {
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    int bounty =(int) (secondGoldProduction.ressource *
                                   secondGoldProduction.so.bountyPercentage);
                    secondGoldProduction.DecreaseRessource(bounty);
                    IncreaseRessource(bounty);
                    break;
                }
                case Enums.Team.Team2:
                {
                   int bounty =(int) (firstTeamGoldProduction.ressource *
                                   firstTeamGoldProduction.so.bountyPercentage);
                    firstTeamGoldProduction.DecreaseRessource(bounty);
                    IncreaseRessource(bounty);
                    break;
                }
            }
        }

        public void TryBreakCurrentStreak()
        {
            if (CurrentStreakLevel == 0) return;
            if (!allCapturesPoint.All(point => point.team == team))
            {
                CurrentStreakLevel = 0;
            }
        }

        public override void IncreaseRessource(int amount)
        {
            Ressource += amount;
            if (so.ressourceMax < Ressource)
                Ressource = so.ressourceMax;

            var soStreak = so.streaks[CurrentStreakLevel];
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

                if (allCapturesPoint.Any(point => point.team == team))
                {
                    // convert
                    if (CurrentStreakLevel != so.streaks.Count - 1)
                        CurrentStreakLevel++;
                }
            }
            //  convert en gland automatiquement 
            // streaks

            // casser une streak ajouter event restart
        }

        public void RequestDecreaseRessource(int amount)
        {
            photonView.RPC("DecreaseRessource", RpcTarget.MasterClient, amount);
        }

        [PunRPC]
        public override void DecreaseRessource(int amount)
        {
            Ressource -= amount;
            if (so.ressourceMin > ressource)
                Ressource = 0;
        }

        public override void UpdateFeedback(int value)
        {
            if (uiManager != null)
            {
                uiManager.UpdateGoldText(value, team);
            }
            
        }

        public override void ReadSerializeView(PhotonStream stream)
        {
            base.ReadSerializeView(stream);
            CurrentStreakLevel = (int) stream.ReceiveNext();
        }

        public override void WritingSerializeView(PhotonStream stream)
        {
            base.WritingSerializeView(stream);
            stream.SendNext( CurrentStreakLevel);
        }
    }
}