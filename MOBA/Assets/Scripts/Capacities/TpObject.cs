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
        private float currentTimer;
        [SerializeField] private GameObject renderer;
        private float tpObjectCurveTime;
        private float tpObjectCurveTimeRatio;
        AnimationCurve tpObjectCurve ;
        private float tpObjectCurveYPosition;

        private bool isActive;
        public void SetUp(TpCapacity tpCapacity)
        {
            this.tpCapacity = tpCapacity;
            transform.position = this.tpCapacity.startPosition;
            ChangeTeamRPC((byte)tpCapacity.caster.team);
            currentTimer = 0;
            tpObjectCurve = tpCapacity.tpCapacitySo.tpObjectCurve;
            tpObjectCurveTime = tpCapacity.tpCapacitySo.tpObjectCurveTime;
            tpObjectCurveYPosition = tpCapacity.tpCapacitySo.tpObjectCurveYPosition;
            Debug.Log(tpCapacity.endPosition);
            RequestActivate();
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
            renderer.SetActive(true);
            transform.position = startPos;
        }

        [PunRPC]
        public void DeactivateRPC()
        {
            DeactivateTpObject();
        }

       public void DeactivateTpObject()
        {
            isActive = false;
            renderer.SetActive(false);
        }

        protected override void OnUpdate()
        {
        
            if(!PhotonNetwork.IsMasterClient || !isActive) return;
            if (currentTimer < tpObjectCurveTime)
                currentTimer += Time.deltaTime;
            else
            {
                tpCapacity.InitiateCooldown();
                tpCapacity.champion.RequestMoveChampion(transform.position);
                RequestDeactivate();
            }

            tpObjectCurveTimeRatio = currentTimer / tpObjectCurveTime;
            transform.position = Vector3.Lerp(tpCapacity.startPosition, tpCapacity.endPosition,
                tpObjectCurveTimeRatio);
            var transformPosition = renderer.transform.position;
            var tpObjectCurve = tpCapacity.tpCapacitySo.tpObjectCurve;
            var tpObjectCurveYPosition = tpCapacity.tpCapacitySo.tpObjectCurveYPosition;
            transformPosition.y = tpObjectCurve.Evaluate(tpObjectCurveTimeRatio) *
                                  tpObjectCurveYPosition;
            renderer.transform.position = transformPosition;
            base.OnUpdate();
        }
    }
}