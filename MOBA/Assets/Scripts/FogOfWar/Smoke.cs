using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using GameStates;
using Photon.Pun;
using UnityEngine;

namespace Entities.FogOfWar
{
    public class Smoke : Entity
    {
        private TimerOneCount smokeTimer;
        private Entity smokeRef;
        [SerializeField] private ParticleSystem[] particleSystems;
        private CurveMovementCapacity tpCapacity;

        protected override void OnStart()
        {
            base.OnStart();
            if (PhotonNetwork.IsMasterClient)
            {
                smokeTimer = new TimerOneCount(0);
                smokeTimer.TickTimerEvent += DeactivateSmoke;
            }
        }

        public IEnumerator SetUp(CurveMovementCapacity tpCapacity, float duration, Entity smokeRef, Vector3 pos)
        {
            yield return new WaitForEndOfFrame();
            smokeTimer.time = duration;
            smokeTimer.InitiateTimer();
            this.smokeRef = smokeRef;
            this.tpCapacity = tpCapacity;
            RequestSmoke(pos, duration);
        }

        void RequestSmoke(Vector3 pos, float time) => photonView.RPC("PlaceSmokeRPC", RpcTarget.All, pos, time);

        [PunRPC]
        void PlaceSmokeRPC(Vector3 pos, float time)
        {
            //AddFOWViewable
            for (int i = 0; i < particleSystems.Length; i++)
            {
                var mainModule = particleSystems[i].main;
                mainModule.simulationSpeed = 1 / time;
            }

            if (GameStateMachine.Instance.GetPlayerTeam() == team)
                ShowElements();
            else
            {
                if (enemiesThatCanSeeMe.Count == 0)
                    HideElements();
            }
        }


        void DeactivateSmoke()
        {
            tpCapacity.InitiateCooldown();
            PoolNetworkManager.Instance.PoolRequeue(smokeRef, this);
        }
       
    }
}