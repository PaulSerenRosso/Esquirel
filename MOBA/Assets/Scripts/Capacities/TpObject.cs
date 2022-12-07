using System.Collections;
using System.Collections.Generic;
using Entities;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class TpObject : Entity
    {
        private TpCapacity tpCapacity;
        private TpCapacitySO tpCapacitySo;
        private float currentTimer;
        [SerializeField] private MeshRenderer renderer;
        private float tpObjectCurveTime;
        private float tpObjectCurveTimeRatio;
        AnimationCurve tpObjectCurve ;
        private float tpObjectCurveYPosition;
        private bool isActive;
        private Vector3 startPosition;
        private Champion.Champion champion;
        private Vector3 endPosition;
        public void RequestSetupRPC(byte capacityIndex, int championIndex, Vector3 endPos)
        {
            photonView.RPC("SetUpRPC", RpcTarget.All, capacityIndex, championIndex, endPos);
        }
        [PunRPC] 
        void SetUpRPC(byte capacityIndex, int championIndex, Vector3 endPos)
        {
            champion =(Champion.Champion) EntityCollectionManager.GetEntityByIndex(championIndex);
            this.tpCapacity =(TpCapacity) champion.activeCapacities[capacityIndex];
            this.tpCapacitySo = tpCapacity.tpCapacitySo;
            SyncChangeTeamRPC((byte)champion.team);
            endPosition = endPos;
            currentTimer = 0;
            tpObjectCurve = tpCapacitySo.tpObjectCurve;
            tpObjectCurveTime = tpCapacitySo.tpObjectCurveTime;
            tpObjectCurveYPosition = tpCapacitySo.tpObjectCurveYPosition;
            Debug.Log(champion.transform.position);
            ActivateRPC(champion.transform.position);
                renderer.enabled =true;
                
            if (champion.photonView.IsMine)
            {
                ShowElements();
            }
            else
            {
                HideElements();
            }
        }

        public void RequestActivate()
        {
            photonView.RPC("ActivateRPC", RpcTarget.All, tpCapacity.startPosition);
        }

        public void RequestDeactivate()
        {
            photonView.RPC("DeactivateRPC", RpcTarget.All);
        }
        [PunRPC]
        public void ActivateRPC(Vector3 startPos)
        {
            ActivateTpObject(startPos);
        }

       public  void ActivateTpObject(Vector3 startPos)
        {
            isActive = true;
            startPosition = startPos;
            transform.position = startPos;
            Debug.Log(startPos);
        }

        [PunRPC]
        public void DeactivateRPC()
        {
            DeactivateTpObject();
        }

       public void DeactivateTpObject()
        {
            isActive = false;
            HideElements();
            renderer.enabled =false;
        }

        protected override void OnUpdate()
        {
        
            // je vois le problème lol le time deltatime ça quelle plaisir
            if(!isActive) return;
            if (currentTimer < tpObjectCurveTime)
                currentTimer += Time.deltaTime;
            else 
            {
                if (PhotonNetwork.IsMasterClient)
                {
                tpCapacity.InitiateCooldown();
                }
                champion.MoveChampionRPC(transform.position);
                DeactivateTpObject();
            }

            tpObjectCurveTimeRatio = currentTimer / tpObjectCurveTime;
            transform.position = Vector3.Lerp(startPosition, endPosition,
                tpObjectCurveTimeRatio);
            var transformPosition = renderer.transform.position;
            var tpObjectCurve = tpCapacitySo.tpObjectCurve;
            var tpObjectCurveYPosition = tpCapacitySo.tpObjectCurveYPosition;
            transformPosition.y = tpObjectCurve.Evaluate(tpObjectCurveTimeRatio) *
                                  tpObjectCurveYPosition;
            renderer.transform.position = transformPosition;
            base.OnUpdate();
        }
    }
}