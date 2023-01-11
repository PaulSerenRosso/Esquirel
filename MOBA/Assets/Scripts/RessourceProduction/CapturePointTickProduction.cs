using System;
using System.Collections;
using System.Collections.Generic;
using CapturePoint;
using Photon.Pun;
using UnityEngine;

namespace RessourceProduction
{
    public abstract class CapturePointTickProduction<T, SO> : RessourceTickProduction<T, SO>
        where SO : CapturePointTickProductionSO<T>
    {
        protected CapturePoint.CapturePoint[] allCapturesPoint;
        [SerializeField] protected Enums.Team team;
        
        protected override void OnStart()
        {
            base.OnStart();
            StartCoroutine(WaitForAddEventToCapturePoint());

        }

        IEnumerator WaitForAddEventToCapturePoint()
        {
            yield return new WaitForEndOfFrame();
            AddEventToCapturePoint();
        }

        private void AddEventToCapturePoint()
        {
            for (int i = 0; i < allCapturesPoint.Length; i++)
            {
                switch (team)
                {
                    case Enums.Team.Team1:
                    {
                        allCapturesPoint[i].firstTeamState.enterStateEvent += InitiateRessourceProductionTimer;
                        allCapturesPoint[i].firstTeamState.exitStateEvent += CancelRessourceProductionTimer;
                        break;
                    }

                    case Enums.Team.Team2:
                    {
                        allCapturesPoint[i].secondTeamState.enterStateEvent += InitiateRessourceProductionTimer;
                        allCapturesPoint[i].secondTeamState.exitStateEvent += CancelRessourceProductionTimer;
                        break;
                    }
                }
            }
        }
    }
}