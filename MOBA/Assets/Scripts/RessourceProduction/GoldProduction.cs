using System;
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
using UnityEngine.Rendering;

namespace RessourceProduction
{
    public class GoldProduction : CapturePointTickProduction<int, GoldProductionSO>
    {
        int currentBounty = 0;

        private int currentStreakLevel;
        private UIManager uiManager;
        public static GoldProduction firstTeamGoldProduction;
        public static GoldProduction secondGoldProduction;

        public event GlobalDelegates.NoParameterDelegate breakStreakEvent;

        public event GlobalDelegates.TwoParameterDelegate<int, int> triggerStreakEvent;

        protected override void OnStart()
        {
            allCapturesPoint = CapturePointCollectionManager.instance.GoldCapturePoints;
            var playerTeam = GameStateMachine.Instance.GetPlayerTeam();
            if (playerTeam == team)
            {
                breakStreakEvent += MessagePopUpManager.Instance.SendAllyBreakStreak;
                triggerStreakEvent += MessagePopUpManager.Instance.SendAllyIncreaseStreak;
            }
            else
            {
                breakStreakEvent += MessagePopUpManager.Instance.SendEnemyBreakStreak;
                triggerStreakEvent += MessagePopUpManager.Instance.SendEnemyIncreaseStreak;
            }

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
            uiManager.UpdateGoldText(Ressource, so.streaks[currentStreakLevel], team);
            SyncSetCurrentStreakRPC(0, true);
        }

        // aura fonctionne 
        // le lost se lance pas biens
        // le streak cassé non plus
        public void LinkBounty(Champion enemyChampion)
        {
            if (PhotonNetwork.IsMasterClient)
                enemyChampion.OnDie += ()=> IncreaseRessourceWithBounty(enemyChampion);
        }

        public void IncreaseRessourceWithBounty(Champion enemyChampion)
        {
            switch (team)
            {
                case Enums.Team.Team1:
                {
                    var newBounty = (int)(secondGoldProduction.ressource *
                                          secondGoldProduction.so.bountyPercentage);
                    RequestSetCurrentBounty(newBounty, enemyChampion.entityIndex);
                    secondGoldProduction.DecreaseRessource(newBounty);
                    IncreaseRessource(newBounty);
                    break;
                }
                case Enums.Team.Team2:
                {
                    var newBounty = (int)(firstTeamGoldProduction.ressource *
                                          firstTeamGoldProduction.so.bountyPercentage);
                    RequestSetCurrentBounty(newBounty, enemyChampion.entityIndex);
                    firstTeamGoldProduction.DecreaseRessource(newBounty);
                    IncreaseRessource(newBounty);
                    break;
                }
            }
        }


        public void TryBreakCurrentStreak()
        {
            if (currentStreakLevel == 0) return;
            if (allCapturesPoint.All(point => point.team != team))
            {
                currentStreakLevel = 0;
                RequestSetCurrentStreak(0);
            }
        }

        public override void IncreaseRessource(int amount)
        {
            Ressource += amount;
            if (so.ressourceMax < Ressource)
                Ressource = so.ressourceMax;

            var soStreak = so.streaks[currentStreakLevel];
            if (ressource >= soStreak)
            {
                DecreaseRessource(soStreak);
                switch (team)
                {
                    case Enums.Team.Team1:{
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
                    RequestSetCurrentStreak(currentStreakLevel);
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
                uiManager.UpdateGoldText(value, so.streaks[currentStreakLevel], team);
            }
        }


        void RequestSetCurrentStreak(int streakIndex)
        {
            photonView.RPC("SyncSetCurrentStreakRPC", RpcTarget.All, streakIndex, false);
        }

        [PunRPC]
        void SyncSetCurrentStreakRPC(int streakIndex, bool start)
        {
            if (!start) {
                switch (team) {
                    case Enums.Team.Neutral:
                        break;
                    case Enums.Team.Team1:
                        if (uiManager != null) uiManager.Team01Exchange();
                        break;
                    case Enums.Team.Team2:
                        if (uiManager != null) uiManager.Team02Exchange();
                        break;
                    default: throw new ArgumentOutOfRangeException();
                }
            }
            
            if (currentStreakLevel > 0 && streakIndex == 0)
                breakStreakEvent?.Invoke();
            else if (currentStreakLevel < streakIndex)
            {
                triggerStreakEvent?.Invoke((int)so.victoryAmount, so.streaks[currentStreakLevel]);
                ;
            }

            currentStreakLevel = streakIndex;
            UIManager.Instance.UpdateStreak(currentStreakLevel, so.streaks[currentStreakLevel], team);
        }

        void RequestSetCurrentBounty(int bounty, int enemyChampionIndex)
        {
            photonView.RPC("SyncSetCurrentBountyRPC", RpcTarget.All, bounty, enemyChampionIndex);
        }

        [PunRPC]
        void SyncSetCurrentBountyRPC(int bounty, int enemyChampionIndex)
        {
            currentBounty = bounty;

            var playerChampion = GameStateMachine.Instance.GetPlayerChampion();
            var enemyChampion = EntityCollectionManager.GetEntityByIndex(enemyChampionIndex);
            if (enemyChampion == playerChampion)
            {
                MessagePopUpManager.Instance.SendPlayerDie(bounty);
            }
            else if (enemyChampion.team == playerChampion.team)
            {
                MessagePopUpManager.Instance.SendAllyPlayerDie(bounty);
            }
            else
            {
                MessagePopUpManager.Instance.SendEnemyPlayerDie(currentBounty);
            }
        }
    }
}